terraform {
  required_providers {

    docker = {
    source  = "kreuzwerker/docker"
    version = "~> 3.0.2"
    }

    google = {
      source = "hashicorp/google"
      version = "5.6.0"
    }

    kubernetes = {
    source = "hashicorp/kubernetes"
    version = ">= 2.35.0"
  }

  }
}

provider "docker" {
  registry_auth {
    address  = var.docker_registry_address
    username = "oauth2accesstoken"
    password = data.google_service_account_access_token.sa.access_token
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone = var.zone
  credentials = file(var.private_key_location)
}

data "google_service_account_access_token" "sa" {
  target_service_account = var.access_token_target_service_account
  scopes                 = [ "cloud-platform" ]
}

data "google_client_config" "default" {}


provider "kubernetes" {
  host                   = "https://${module.gcp.kubernetes_cluster_host}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    module.gcp.kubernetes_cluster.master_auth[0].cluster_ca_certificate,
  )
}