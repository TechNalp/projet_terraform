resource "kubernetes_secret" "redis_info" {
  metadata {
    name = "redis-info"
  }

  data = {
    redis_host = var.redis_vm_ip == null ?  "redis" : var.redis_vm_ip
    password = var.redis_password == null ? "" : var.redis_password
  }
}

