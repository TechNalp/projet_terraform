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


module "k8s" {
  source = "../modules/k8s"

  count = var.create_k8s ? 1 : 0
  project_id = var.project_id
  private_key_location = var.private_key_location
  region = var.region
  zone = var.zone

  docker_registry_address = var.docker_registry_address

  path_to_manifests = var.path_to_manifests
  pvc_manifests = var.pvc_manifest
  deployment_manifests = var.deployment_manifests
  service_manifests = var.service_manifests
  job_manifests = var.job_manifests
}