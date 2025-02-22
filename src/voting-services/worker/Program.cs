using System;
using System.Data.Common;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Net.NetworkInformation;
using System.Threading;
using Newtonsoft.Json;
using Npgsql;
using StackExchange.Redis;

namespace Worker
{
    public class Program
    {
        private static String MakeRedisConnString(string hostname, string password) => hostname + (password != null ? (",password=" + password) : "");

        public static int Main(string[] args)
        {
            // Get environment variables from the system, all of them are optional and independent
            var pgHostEnv = System.Environment.GetEnvironmentVariable("POSTGRES_HOST");
            var pgUsernameEnv = System.Environment.GetEnvironmentVariable("POSTGRES_USERNAME");
            var pgPasswordEnv = System.Environment.GetEnvironmentVariable("POSTGRES_PASSWORD");
            var redisHostEnv = System.Environment.GetEnvironmentVariable("REDIS_HOST");
            var redisPasswordEnv = System.Environment.GetEnvironmentVariable("REDIS_PASSWORD");

            // construct the according strings, taking into account defaults, etc.
            var pgHost = pgHostEnv != null ? pgHostEnv : "db";  // default host is `db`
            var pgUsername = pgUsernameEnv != null ? pgUsernameEnv : "postgres";
            var pgPassword = pgPasswordEnv != null ? pgPasswordEnv : "postgres";
            var redisHost = redisHostEnv != null ? redisHostEnv : "redis";  // default redis host is `redis`
            var redisPassword = redisPasswordEnv != null ? redisPasswordEnv : null;  // redis password is optional (but if set, host must be set too)

            // construct the final connection string and log
            var pgConnString = "Server=" + pgHost + ";Username=" + pgUsername + ";Password=" + pgPassword + ";";
            // var redisConnString = redisHost + (redisPassword != null ? (",password=" + redisPassword) : "");
            Console.WriteLine("DEBUG pgConnString = " + pgConnString);
            Console.WriteLine("DEBUG redisConnString = " + MakeRedisConnString(redisHost, redisPassword));

            try
            {
                var pgsql = OpenDbConnection(pgConnString);
                var redisConn = OpenRedisConnection(redisHost, redisPassword);
                var redis = redisConn.GetDatabase();

                // Keep alive is not implemented in Npgsql yet. This workaround was recommended:
                // https://github.com/npgsql/npgsql/issues/1214#issuecomment-235828359
                var keepAliveCommand = pgsql.CreateCommand();
                keepAliveCommand.CommandText = "SELECT 1";

                var definition = new { vote = "", voter_id = "" };
                while (true)
                {
                    // Slow down to prevent CPU spike, only query each 100ms
                    Thread.Sleep(100);

                    // Reconnect redis if down
                    if (redisConn == null || !redisConn.IsConnected)
                    {
                        Console.WriteLine("Reconnecting Redis");
                        redisConn = OpenRedisConnection(redisHost, redisPassword);
                        redis = redisConn.GetDatabase();
                    }
                    string json = redis.ListLeftPopAsync("votes").Result;
                    if (json != null)
                    {
                        var vote = JsonConvert.DeserializeAnonymousType(json, definition);
                        Console.WriteLine($"Processing vote for '{vote.vote}' by '{vote.voter_id}'");
                        // Reconnect DB if down
                        if (!pgsql.State.Equals(System.Data.ConnectionState.Open))
                        {
                            Console.WriteLine("Reconnecting DB");
                            pgsql = OpenDbConnection(pgConnString);
                        }
                        else
                        { // Normal +1 vote requested
                            UpdateVote(pgsql, vote.voter_id, vote.vote);
                        }
                    }
                    else
                    {
                        keepAliveCommand.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine(ex.ToString());
                return 1;
            }
        }

        private static NpgsqlConnection OpenDbConnection(string connectionString)
        {
            NpgsqlConnection connection;

            while (true)
            {
                try
                {
                    connection = new NpgsqlConnection(connectionString);
                    connection.Open();
                    break;
                }
                catch (SocketException)
                {
                    Console.Error.WriteLine("Waiting for db '" + connectionString + "'");
                    Thread.Sleep(1000);
                }
                catch (DbException)
                {
                    Console.Error.WriteLine("Waiting for db '" + connectionString + "'");
                    Thread.Sleep(1000);
                }
            }

            Console.Error.WriteLine("Connected to db '" + connectionString + "'");

            var command = connection.CreateCommand();
            command.CommandText = @"CREATE TABLE IF NOT EXISTS votes (
                                        id VARCHAR(255) NOT NULL UNIQUE,
                                        vote VARCHAR(255) NOT NULL
                                    )";
            command.ExecuteNonQuery();

            return connection;
        }

        private static ConnectionMultiplexer OpenRedisConnection(string hostname, string password)
        {
            ConnectionMultiplexer connection;

            // Use IP address to workaround https://github.com/StackExchange/StackExchange.Redis/issues/410
            Console.WriteLine($"Looking for redis at '{hostname}'");
            var ipAddress = GetIp(hostname);
            Console.WriteLine($"Found for redis at '{ipAddress}'");

            var connectionString = MakeRedisConnString(ipAddress, password);

            while (true)
            {
                try
                {
                    Console.Error.WriteLine("Connecting to Redis");
                    connection = ConnectionMultiplexer.Connect(connectionString);
                    Console.Error.WriteLine("Connected to redis '" + connectionString + "'");
                    return connection;
                }
                catch (RedisConnectionException)
                {
                    Console.Error.WriteLine("Waiting for redis '" + ipAddress + "'");
                    Thread.Sleep(1000);
                }
            }
        }

        private static string GetIp(string hostname)
            => Dns.GetHostEntry(hostname)
                .AddressList
                .First(a => a.AddressFamily == AddressFamily.InterNetwork)
                .ToString();

        private static void UpdateVote(NpgsqlConnection connection, string voterId, string vote)
        {
            var command = connection.CreateCommand();
            try
            {
                command.CommandText = "INSERT INTO votes (id, vote) VALUES (@id, @vote)";
                command.Parameters.AddWithValue("@id", voterId);
                command.Parameters.AddWithValue("@vote", vote);
                command.ExecuteNonQuery();
            }
            catch (DbException)
            {
                command.CommandText = "UPDATE votes SET vote = @vote WHERE id = @id";
                command.ExecuteNonQuery();
            }
            finally
            {
                command.Dispose();
            }
        }
    }
}
