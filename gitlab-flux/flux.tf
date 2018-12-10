locals {
  flux_release_name = "${replace(var.gitlab_project,"/","-")}-flux"
  secret_name       = "flux-ssh-identity-secret"
}

resource "tls_private_key" "flux_ssh_identity" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "kubernetes_secret" "flux_ssh_identity" {
  metadata {
    name      = "${local.secret_name}"
    namespace = "flux"
  }

  data {
    identity = "${tls_private_key.ssh_identity.private_key_pem}"
  }
}

resource "gitlab_deploy_key" "deploy_key" {
  project  = "${var.gitlab_project}"
  title    = "${local.flux_release_name} flux deploy key"
  key      = "${tls_private_key.ssh_identity.public_key_openssh}"
  can_push = true
}

resource "helm_repository" "weaveworks" {
  name = "weaveworks"
  url  = "https://weaveworks.github.io/flux"
}

resource "helm_release" "flux" {
  name       = "${local.flux_release_name}"
  repository = "${helm_repository.weaveworks.metadata.0.name}"
  chart      = "flux"

  namespace = "flux"
  version   = "${var.flux_chart_version}"

  set {
    name  = "git.url"
    value = "git@gitlab.com:${var.gitlab_project}.git"
  }

  set {
    name  = "git.user"
    value = "${var.git_user}"
  }

  set {
    name  = "git.email"
    value = "${var.git_email}"
  }

  set {
    name  = "git.branch"
    value = "master"
  }

  set {
    name  = "git.ciSkip"
    value = true
  }

  set {
    name  = "git.label"
    value = "flux-sync"
  }

  set {
    name  = "registry.rps"
    value = "2"
  }

  set {
    name  = "helmOperator.create"
    value = true
  }

  set {
    name  = "helmOperator.git.chartsPath"
    value = "charts"
  }

  set {
    name  = "helmOperator.git.pollInterval"
    value = "1m"
  }

  set {
    name  = "helmOperator.tillerNamespace"
    value = "${var.tiller_namespace}"
  }

  set {
    name  = "git.secretName"
    value = "${local.secret_name}"
  }
}
