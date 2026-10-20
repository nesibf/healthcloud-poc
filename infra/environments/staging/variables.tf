variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "github_repository" {
  type = string
}

variable "notification_email" {
  type = string
}

variable "environment" {
  type = string
}

variable "node_count" {
  type = number
}

variable "deletion_protection" {
  type = bool
}

locals {
  name = "hc-${var.environment}"
}

output "github_provider" {
  value = module.identity.provider
}

output "github_service_account" {
  value = module.identity.service_account
}

output "cluster" {
  value = module.gke.cluster_name
}

output "image_repo" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.images.repository_id}"
}
