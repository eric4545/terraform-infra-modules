provider "github" {
  version      = "~> 1.3"
  token        = "${var.github_token}"
  organization = "${var.github_organization}"
}

provider "null" {
  version = "~> 1.0"
}

provider "external" {
  version = "~> 1.0"
}

provider "helm" {}
