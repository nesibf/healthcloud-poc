variable "name" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "node_count" {
  type = number
}

variable "deletion_protection" {
  type = bool
}

output "cluster_name" {
  value = google_container_cluster.main.name
}
