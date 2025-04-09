provider "google" {
  project = "my-project-44865-424207"
  region  = "us-east1"
}

# terraform {
#   backend "gcs" {
#     bucket = "kontrol-dev-terraform-backend"
#     prefix = "terraform/dev"
#   }
#   required_providers {
#     kubectl = {
#       source  = "gavinbunney/kubectl"
#       version = ">= 1.7.0"
#     }
#     kubernetes = {
#       source  = "hashicorp/kubernetes"
#       version = ">= 2.0.0"
#     }
#   }
# }

