locals {
  flux_release_name = "${replace(var.gitlab_project,"/","-")}-flux"
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
}

data "external" "flux_ssh_key" {
  depends_on = ["helm_release.flux"]

  program = ["/bin/sh", "-c",
    <<SCRIPT
SSH_KEY=$(fluxctl identity --k8s-fwd-ns=flux) && \
echo "{\"key\":\"$SSH_KEY\"}"
SCRIPT
    ,
  ]
}

resource "gitlab_deploy_key" "deploy_key" {
  project  = "${var.gitlab_project}"
  title    = "${local.flux_release_name} flux deploy key"
  key      = "${lookup(data.external.flux_ssh_key.result,"key")}"
  can_push = true
}
