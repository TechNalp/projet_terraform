output "default_network" {
  value = data.google_compute_network.default_network
  description = "Gcloud default network"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.cluster.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.cluster.endpoint
  description = "GKE Cluster Host"
}

output "google_client_config" {
  value = data.google_client_config.default
}

output "kubernetes_cluster" {
  value = google_container_cluster.cluster
}