terraform {
  required_providers {
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