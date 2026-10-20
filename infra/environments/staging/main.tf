terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "services" {
  for_each           = toset(["compute.googleapis.com", "container.googleapis.com", "artifactregistry.googleapis.com", "iam.googleapis.com", "iamcredentials.googleapis.com", "sts.googleapis.com", "monitoring.googleapis.com", "logging.googleapis.com"])
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

module "network" {
  source     = "../../modules/network"
  name       = local.name
  region     = var.region
  depends_on = [google_project_service.services]
}

module "gke" {
  source              = "../../modules/gke"
  name                = local.name
  project_id          = var.project_id
  region              = var.region
  network             = module.network.network
  subnetwork          = module.network.subnetwork
  node_count          = var.node_count
  deletion_protection = var.deletion_protection
  depends_on          = [google_project_service.services]
}

resource "google_artifact_registry_repository" "images" {
  location      = var.region
  repository_id = "${local.name}-images"
  format        = "DOCKER"
  depends_on    = [google_project_service.services]
}

module "identity" {
  source            = "../../modules/identity"
  project_id        = var.project_id
  name              = local.name
  github_repository = var.github_repository
  depends_on        = [google_project_service.services]
}

resource "google_artifact_registry_repository_iam_member" "publisher" {
  location   = google_artifact_registry_repository.images.location
  repository = google_artifact_registry_repository.images.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${module.identity.service_account}"
}

module "observability" {
  source             = "../../modules/observability"
  project_id         = var.project_id
  name               = local.name
  notification_email = var.notification_email
  depends_on         = [google_project_service.services]
}
