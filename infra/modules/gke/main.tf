variable "name" { type = string }
variable "project_id" { type = string }
variable "region" { type = string }
variable "network" { type = string }
variable "subnetwork" { type = string }
variable "node_count" { type = number }
variable "deletion_protection" { type = bool }
resource "google_service_account" "nodes" { account_id = "${var.name}-nodes"; display_name = "GKE node identity" }
resource "google_project_iam_member" "logging" { project = var.project_id; role = "roles/logging.logWriter"; member = "serviceAccount:${google_service_account.nodes.email}" }
resource "google_project_iam_member" "metrics" { project = var.project_id; role = "roles/monitoring.metricWriter"; member = "serviceAccount:${google_service_account.nodes.email}" }
resource "google_project_iam_member" "registry" { project = var.project_id; role = "roles/artifactregistry.reader"; member = "serviceAccount:${google_service_account.nodes.email}" }
resource "google_container_cluster" "main" {
  name = var.name; location = var.region; network = var.network; subnetwork = var.subnetwork
  deletion_protection = var.deletion_protection
  remove_default_node_pool = true; initial_node_count = 1
  networking_mode = "VPC_NATIVE"
  ip_allocation_policy { cluster_secondary_range_name = "pods"; services_secondary_range_name = "services" }
  private_cluster_config { enable_private_nodes = true; enable_private_endpoint = false; master_ipv4_cidr_block = "172.16.0.0/28" }
  workload_identity_config { workload_pool = "${var.project_id}.svc.id.goog" }
  release_channel { channel = "REGULAR" }
  logging_service = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  monitoring_config { managed_prometheus { enabled = true } }
  enable_shielded_nodes = true
}
resource "google_container_node_pool" "main" {
  name = "primary"; location = var.region; cluster = google_container_cluster.main.name
  node_count = var.node_count
  node_config {
    machine_type = "e2-standard-2"; service_account = google_service_account.nodes.email
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    metadata = { disable-legacy-endpoints = "true" }
    shielded_instance_config { enable_secure_boot = true; enable_integrity_monitoring = true }
    workload_metadata_config { mode = "GKE_METADATA" }
  }
  depends_on = [google_project_iam_member.logging,google_project_iam_member.metrics,google_project_iam_member.registry]
}
output "cluster_name" { value = google_container_cluster.main.name }
