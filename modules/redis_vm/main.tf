resource "google_compute_instance" "redis" {
  name         = var.redis_vm_configuration.name
  machine_type = var.redis_vm_configuration.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }


  network_interface {
    network = "default"

    access_config {
    }
  }
  
  tags = var.redis_vm_configuration.tags


  metadata_startup_script = templatefile(abspath("${path.root}/${var.redis_vm_configuration.startup_script_location}"),{password = var.redis_vm_configuration.password})

}


resource "google_compute_firewall" "redis" {
  name = "redis-firewall"
  network = var.gcp_default_network.name

  target_tags = var.redis_vm_configuration.tags

  source_ranges = [ "0.0.0.0/0" ]

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }
}




