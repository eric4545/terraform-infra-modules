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

provider "helm" {
  version = "~> 0.6"
}
