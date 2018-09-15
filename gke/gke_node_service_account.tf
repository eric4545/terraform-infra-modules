resource "random_string" "gke_node_sa_account_id" {
  length  = 24
  special = false
  upper   = false
  number  = false
}

locals {
  gke_node_sa_account_id          = "gke-${random_string.gke_node_sa_account_id.result}"
  gke_node_sa_account_description = "GKE ${local.cluster_name} node service account"
}

resource "google_service_account" "gke_node" {
  account_id   = "${local.gke_node_sa_account_id}"
  display_name = "${local.gke_node_sa_account_description}"
}

resource "google_project_iam_member" "gke_node_log_writer" {
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.gke_node.email}"
}

resource "google_project_iam_member" "gke_node_metric_writer" {
  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.gke_node.email}"
}

resource "google_project_iam_member" "gke_node_monitoring_viewer" {
  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.gke_node.email}"
}

# Allow to pull image from same project
resource "google_project_iam_member" "gke_node_gcr_viewer" {
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.gke_node.email}"
}
