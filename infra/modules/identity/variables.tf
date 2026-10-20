variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "github_repository" {
  type = string
}

variable "github_branch" {
  type    = string
  default = "main"
}

output "provider" {
  value = google_iam_workload_identity_pool_provider.github.name
}

output "service_account" {
  value = google_service_account.publisher.email
}

output "service_account_name" {
  value = google_service_account.publisher.name
}
