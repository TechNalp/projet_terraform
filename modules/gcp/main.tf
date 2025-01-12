data "google_compute_network" "default_network" {
  name = "default"
}

resource "google_container_cluster" "cluster" {
  name     = "${var.project_id}-gke"
  location = var.region

  remove_default_node_pool = false
  initial_node_count       = 1

  network    = data.google_compute_network.default_network.name
}

data "google_client_config" "default" {}

