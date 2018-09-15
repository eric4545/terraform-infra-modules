resource "random_string" "gcr_sa_account_id" {
  length  = 28
  special = false
  upper   = false
  number  = false
}

locals {
  gcr_sa_account_id          = "${random_string.gcr_sa_account_id.result}"
  gcr_sa_account_description = "${local.cluster_name} GCR Viewer"
}

resource "google_service_account" "gcr_viewer" {
  provider     = "google.gcr"
  account_id   = "${local.gcr_sa_account_id}"
  display_name = "${local.gcr_sa_account_description}"
}

# https://cloud.google.com/container-registry/docs/access-control
resource "google_project_iam_member" "gcr_viewer" {
  provider = "google.gcr"

  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.gcr_viewer.email}"
}

# https://www.terraform.io/docs/providers/google/r/google_service_account_key.html
resource "google_service_account_key" "gcr_viewer" {
  provider = "google.gcr"

  service_account_id = "${google_service_account.gcr_viewer.name}"
}

locals {
  gcr_dockercfg = {
    "https://us.gcr.io" = {
      # email    = ""
      username = "_json_key"
      password = "${base64decode(google_service_account_key.gcr_viewer.private_key)}"
    }
  }
}
