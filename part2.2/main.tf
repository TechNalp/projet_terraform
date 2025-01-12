module "docker_image" {
  source = "../modules/docker_images"
  
  project_id = var.project_id

  docker_registry_address = var.docker_registry_address
  push_on_remote_registry = true
}


module "gcp" {
  source = "../modules/gcp"

  project_id = var.project_id
  private_key_location = var.private_key_location
  region = var.region
  zone = var.zone
}


module "redis_vm" {
  source = "../modules/redis_vm"
  
  gcp_default_network = module.gcp.default_network
  zone = var.zone
  redis_vm_configuration = var.redis_vm_configuration

  depends_on = [ module.gcp ]
}


module "k8s" {
  source = "../modules/k8s"

  count = var.create_k8s ? 1 : 0
  project_id = var.project_id
  private_key_location = var.private_key_location
  region = var.region
  zone = var.zone

  docker_registry_address = var.docker_registry_address

  path_to_manifests = var.path_to_manifests
  pvc_manifests = var.pvc_manifests
  deployment_manifests = var.deployment_manifests
  service_manifests = var.service_manifests

  redis_vm_ip = module.redis_vm.redis_vm_ip
  redis_password = var.redis_vm_configuration.password
  job_manifests = var.job_manifests
}



# resource "kubernetes_env" "for_worker" {
#   kind = "Deployment"
#   api_version = "apps/v1"
#   container = "worker-container"

#   metadata {
#     name="worker-deplt"
#   }
#   env {
#     name = "REDIS_HOST"
#     value = module.redis_vm.redis_vm_ip
#   }

#   env {
#     name = "REDIS_PASSWORD"
#     value = var.redis_vm_configuration.password
#   }
#   depends_on = [ module.k8s ]
# }

# resource "kubernetes_env" "for_vote" {
#   kind = "Deployment"
#   api_version = "apps/v1"
#   container = "vote-container"
#   metadata {
#     name="vote-deplt"
#   }
#   env {
#     name = "REDIS_HOST"
#     value = module.redis_vm.redis_vm_ip
#   }

#   env {
#     name = "REDIS_PASSWORD"
#     value = var.redis_vm_configuration.password
#   }

#   depends_on = [ module.k8s ]
# }