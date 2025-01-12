output "redis_vm_ip" {
  value = google_compute_instance.redis.network_interface[0].network_ip
}