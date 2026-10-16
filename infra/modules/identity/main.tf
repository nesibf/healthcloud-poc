variable "project_id" { type = string }
variable "name" { type = string }
variable "github_repository" { type = string }
variable "github_branch" { type = string; default = "main" }
resource "google_iam_workload_identity_pool" "github" { workload_identity_pool_id = "${var.name}-github"; display_name = "GitHub Actions" }
resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"; display_name = "GitHub OIDC"
  attribute_mapping = {
    "google.subject" = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref" = "assertion.ref"
  }
  attribute_condition = "assertion.repository == '${var.github_repository}' && assertion.ref == 'refs/heads/${var.github_branch}'"
  oidc { issuer_uri = "https://token.actions.githubusercontent.com" }
}
resource "google_service_account" "publisher" { account_id = "${var.name}-publisher"; display_name = "GitHub image publisher" }
resource "google_service_account_iam_member" "github" {
  service_account_id = google_service_account.publisher.name
  role = "roles/iam.workloadIdentityUser"
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repository}"
}
output "provider" { value = google_iam_workload_identity_pool_provider.github.name }
output "service_account" { value = google_service_account.publisher.email }
output "service_account_name" { value = google_service_account.publisher.name }
