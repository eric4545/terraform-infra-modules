locals {
  flux_release_name = "${var.github_repo}-flux"
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
    value = "git@github.com:${var.github_repo_owner}/${var.github_repo}.git"
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
    name  = "helmOperator.tillerNamespace"
    value = "${var.tiller_namespace}"
  }
}

data "external" "flux_ssh_key" {
  depends_on = ["helm_release.flux"]

  program = ["/bin/sh", "-c",
    <<SCRIPT
FLUX_POD=$(kubectl get pods -n flux -l "app=flux,release=${helm_release.flux.name}" -o jsonpath="{.items[0].metadata.name}") && \
SSH_KEY=$(kubectl -n flux logs $FLUX_POD | grep identity.pub | cut -d '"' -f2) && \
echo "{\"key\":\"$SSH_KEY\"}"
SCRIPT
    ,
  ]
}

resource "github_repository_deploy_key" "deploy_key" {
  title      = "flux deploy key"
  repository = "${var.github_repo}"
  key        = "${lookup(data.external.flux_ssh_key.result,"key")}"
  read_only  = "false"
}
