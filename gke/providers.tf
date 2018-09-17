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
  version = "~> 1.1"
  host    = "https://${google_container_cluster.primary.endpoint}"
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
