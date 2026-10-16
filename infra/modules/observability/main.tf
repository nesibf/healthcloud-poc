variable "project_id" { type = string }
variable "name" { type = string }
variable "notification_email" { type = string }
resource "google_monitoring_notification_channel" "email" {
  display_name = "${var.name} oncall"; type = "email"; labels = { email_address = var.notification_email }
}
resource "google_monitoring_alert_policy" "pod_restarts" {
  display_name = "${var.name}: frequent container restarts"; combiner = "OR"
  conditions {
    display_name = "Container restarts > 3 / 5m"
    condition_threshold {
      filter = "resource.type=\"k8s_container\" AND metric.type=\"kubernetes.io/container/restart_count\""
      comparison = "COMPARISON_GT"; threshold_value = 3; duration = "300s"
      aggregations { alignment_period = "300s"; per_series_aligner = "ALIGN_DELTA" }
    }
  }
  notification_channels = [google_monitoring_notification_channel.email.name]
}
resource "google_monitoring_dashboard" "overview" {
  dashboard_json = jsonencode({
    displayName = "${var.name} GKE Overview"
    gridLayout = { columns = 2, widgets = [
      { title = "Container CPU", xyChart = { dataSets = [{ timeSeriesQuery = { timeSeriesFilter = { filter = "metric.type=\"kubernetes.io/container/cpu/core_usage_time\" AND resource.type=\"k8s_container\"", aggregation = { alignmentPeriod = "60s", perSeriesAligner = "ALIGN_RATE" } } }, plotType = "LINE" }], yAxis = { label = "CPU cores", scale = "LINEAR" } } },
      { title = "Container restarts", xyChart = { dataSets = [{ timeSeriesQuery = { timeSeriesFilter = { filter = "metric.type=\"kubernetes.io/container/restart_count\" AND resource.type=\"k8s_container\"", aggregation = { alignmentPeriod = "300s", perSeriesAligner = "ALIGN_DELTA" } } }, plotType = "LINE" }], yAxis = { label = "Restarts", scale = "LINEAR" } } }
    ] }
  })
}
