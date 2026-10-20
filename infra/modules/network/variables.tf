variable "name" {
  type = string
}

variable "region" {
  type = string
}

output "network" {
  value = google_compute_network.main.id
}

output "subnetwork" {
  value = google_compute_subnetwork.main.id
}
