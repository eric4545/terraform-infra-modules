provider "google" {
  version = "~> 1.13"
  project = "${var.gcp_project}"
}

provider "google" {
  alias   = "gcr"
  version = "~> 1.12"
  project = "${var.gcr_project}"
}

provider "kubernetes" {
  version                = "~> 1.1"
  host                   = "https://${google_container_cluster.primary.endpoint}"
  username               = "${google_container_cluster.primary.master_auth.0.username}"
  password               = "${google_container_cluster.primary.master_auth.0.password}"
  client_certificate     = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
  client_key             = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
}

provider "external" {
  version = "~> 1.0"
}

provider "null" {
  version = "~> 1.0"
}

provider "template" {
  version = "~> 1.0"
}

provider "random" {
  version = "~> 1.3"
}
