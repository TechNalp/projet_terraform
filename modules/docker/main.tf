resource "docker_container" "db" {
  name  = "db"
  image = var.docker_images.postgresql.image_id

  env = [
    "POSTGRES_PASSWORD=postgres"
  ]
  
  volumes {
    volume_name = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }
  volumes {
    container_path = "/healthchecks/postgres.sh"
    host_path      =  abspath("${path.module}/../../src/healthchecks/postgres.sh")
  }

  healthcheck {
    test = [ "CMD", "bash", "/healthchecks/postgres.sh" ]
    interval = "15s"
    start_period = "10s"
    retries = 3
  }
}


resource "docker_container" "redis" {
  name  = "redis"
  image = var.docker_images.redis.image_id

  volumes {
    container_path = "/healthchecks/redis.sh"
    host_path      = abspath("${path.module}/../../src/healthchecks/redis.sh")
  }

  healthcheck {
    test = [ "CMD", "sh", "/healthchecks/redis.sh" ]
    interval = "15s"
    start_period = "10s"
    retries = 3
  }
  
}

resource "docker_container" "nginx" {
  name = "nginx"
  image = var.docker_images.nginx.image_id

  depends_on = [docker_container.vote]

   ports {
    internal = "8000"
    external = "8000"
  }

  dynamic host {
    for_each = docker_container.vote
    
    content {
      host = host.value.name
      ip = host.value.network_data[0].ip_address
    }
  }
}


resource "docker_container" "result" {
  name = "result"
  image = var.docker_images.result.image_id

  host {
    host = docker_container.db.name
    ip = docker_container.db.network_data[0].ip_address
  }

  ports {
    internal = 80
    external = 5050
  }

  ports {
    internal = 9229
    external = 9229
  }

  depends_on = [ docker_container.db ]
}

resource "docker_container" "seed" {
  name = "seed"

  image = var.docker_images.seed.image_id

  host {
    host = docker_container.nginx.name
    ip = docker_container.nginx.network_data[0].ip_address
  }

  depends_on = [
    docker_container.nginx
  ]
}



resource "docker_container" "vote" {
  for_each = toset(["vote1","vote2"])
  name = each.value

  image = var.docker_images.vote.image_id

  host {
    host = docker_container.redis.name
    ip = docker_container.redis.network_data[0].ip_address
  }

  depends_on = [
    docker_container.redis
  ]
}

resource "docker_container" "worker" {
  name = "worker"
  image = var.docker_images.worker.image_id

  depends_on = [ docker_container.db, docker_container.redis ]

  host {
    host = docker_container.redis.name
    ip = docker_container.redis.network_data[0].ip_address
  }

  host {
    host = docker_container.db.name
    ip = docker_container.db.network_data[0].ip_address
  }
}