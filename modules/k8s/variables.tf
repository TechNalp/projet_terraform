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


variable "path_to_manifests" {
  description = "path to k8s manifests directory"
  type = string
}


variable "pvc_manifests" {
  description = "list of pvc manifests to use"
  type = list(string)
}

variable "deployment_manifests" {
  description = "list of deployment manifests to use"
  type = list(string)
}

variable "service_manifests" {
  description = "list of service manifests to use"
  type = list(string)
}

variable "job_manifests" {
  description = "list of job manifests to use"
  type = list(string)
}

variable "docker_registry_address" {
  description = "the address of the docker registry"
  type = string
}

variable "redis_vm_ip" {
  description = "the ip of the redis vm"
  type = string
  default = null
}

variable "redis_password" {
  description = "the redis password"
  type = string
  default = null
}
