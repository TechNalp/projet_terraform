variable "project_id" {
  description = "project id"
  type = string
  default = ""
}


variable "push_on_remote_registry" {
  description = "if the builded images must be push to the remote registry"
  type = bool
  default = false
}

variable "docker_registry_address" {
  description = "the address of the docker registry"
  type = string
  default = ""
}