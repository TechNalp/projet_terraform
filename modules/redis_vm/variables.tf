variable "zone" {
  description = "zone"
  type = string
}

variable "gcp_default_network" {
  description = "the default network used by gcp"
  type = object({
    name = string
  })
}

variable "redis_vm_configuration" {
  description = "the configuration of the redis vm"
  type = object({
    name = string
    machine_type = string
    tags = set(string)
    startup_script_location = string
    password = string
  })
}