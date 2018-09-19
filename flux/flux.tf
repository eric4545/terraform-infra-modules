locals {
  flux_release_name = "${var.github_repo}-flux"
}

resource "null_resource" "install_flux" {
  triggers {
    version = "${var.flux_version}"
  }

  provisioner "local-exec" {
    command = <<SCRIPT
helm repo add weaveworks https://weaveworks.github.io/flux && \
helm upgrade ${local.flux_release_name} weaveworks/flux \
    --set git.url="git@github.com:${var.github_repo_owner}/${var.github_repo}.git" \
    --set git.user="${var.git_user}" \
    --set git.email="${var.git_email}" \
    --set git.branch=master \
    --set git.path= \
    --set git.ciSkip=true \
    --set registry.rps="2" \
    --set helmOperator.create=true \
    --set helmOperator.git.chartsPath=charts \
    --set helmOperator.tillerNamespace=${var.tiller_namespace} \
    --version="${var.flux_version}" \
    --install \
    --wait \
    --namespace flux \
    --tiller-namespace=${var.tiller_namespace}
SCRIPT
  }
}

data "external" "flux_ssh_key" {
  depends_on = ["null_resource.install_flux"]

  program = ["/bin/sh", "-c",
    <<SCRIPT
FLUX_POD=$(kubectl get pods -n flux -l "app=flux,release=${local.flux_release_name}" -o jsonpath="{.items[0].metadata.name}") && \
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
