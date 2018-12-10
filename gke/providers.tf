provider "google" {
  version = "~> 1.19"
  project = "${var.gcp_project}"
}

provider "google-beta" {
  version = "~> 1.19"
  project = "${var.gcp_project}"
}

provider "google" {
  alias   = "gcr"
  version = "~> 1.12"
  project = "${var.gcr_project}"
}

# provider "kubernetes" moved to master.tf

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

provider "tls" {
  version = "~> 1.0"
}

# provider "helm" Moved to helm.tf

