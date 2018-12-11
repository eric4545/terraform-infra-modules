provider "google" {
  version = "~> 1.19"
  project = "${var.gcp_project}"
}

provider "google-beta" {
  version = "~> 1.19"
  project = "${var.gcp_project}"
}

data "google_client_config" "default" {}

data "google_container_cluster" "primary" {
  name   = "${var.cluster_name}"
  region = "${var.cluster_region}"
}

provider "kubernetes" {
  version          = "~> 1.4"
  load_config_file = false

  host                   = "https://${data.google_container_cluster.primary.endpoint}"
  token                  = "${data.google_client_config.default.access_token}"
  cluster_ca_certificate = "${base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
}

provider "helm" {
  version = "~> 0.6"

  # Clone from master.tf provider "kubernetes"
  kubernetes {
    host                   = "https://${data.google_container_cluster.primary.endpoint}"
    token                  = "${data.google_client_config.default.access_token}"
    cluster_ca_certificate = "${base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
  }
}

provider "gitlab" {
  version = "~> 1.0"

  token = "${var.gitlab_token}"
}

provider "null" {
  version = "~> 1.0"
}

provider "external" {
  version = "~> 1.0"
}
