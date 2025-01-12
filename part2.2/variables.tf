variable "project_id" {
  description = "project id"
  type = string
}

variable "region" {
  description = "region"
  type = string
}

variable "zone" {
  description = "zone"
  type = string
}

variable "private_key_location" {
  description = "private key location"
  type = string
}

variable "create_k8s" {
  type    = bool
  default = false
}

variable "access_token_target_service_account" {
  description = "service account email who will be get access token"
  type = string
}


variable "docker_registry_address" {
  description = "the address of the docker registry"
  type = string
}

variable "path_to_manifests" {
  description = "path to k8s manifests directory"
  type = string
}

variable "pvc_manifests" {
  description = "list of the pvc manifest name we want to use"
  type = list(string)
}

variable "deployment_manifests" {
  description = "list of deployment manifest name to use"
  type = list(string)
}

variable "service_manifests" {
  description = "list of service manifest to use"
  type = list(string)
}

variable "job_manifests" {
  description = "list of job manifests to use"
  type = list(string)
}


variable "redis_vm_configuration" {
  type = object({
    name = string
    machine_type = string
    tags = set(string)
    startup_script_location = string
    password = string
  })
  default = {
    name = "redis-vm"
    machine_type = "n2-standard-2"
    tags = [ "redis-server" ]
    startup_script_location = "../src/templates/install-redis.sh.tftpl"
    password = "password"
  }
}

