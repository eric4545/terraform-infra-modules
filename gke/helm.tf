# TODO: https://github.com/helm/helm/blob/master/docs/tiller_ssl.md
data "template_file" "helm_rbac" {
  template = "${file("${path.module}/templates/helm_rbac.yaml.tpl")}"
}

# install rbac
resource "null_resource" "helm_rbac" {
  depends_on = ["null_resource.kubectl"]

  provisioner "local-exec" {
    command = <<SCRIPT
cat <<EOF | kubectl --context="${local.kube_context}" apply -f -
${data.template_file.helm_rbac.rendered}
EOF
SCRIPT
  }
}

provider "helm" {
  # Clone from master.tf provider "kubernetes"
  kubernetes {
    host                   = "https://${data.google_container_cluster.primary.endpoint}"
    token                  = "${data.google_client_config.default.access_token}"
    cluster_ca_certificate = "${base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
  }
}

resource "null_resource" "install_helm" {
  depends_on = ["null_resource.kubectl", "null_resource.helm_rbac"]

  provisioner "local-exec" {
    command = <<SCRIPT
    helm init \
      --override 'spec.template.spec.containers[0].command'='{/tiller,--storage=secret}' \
      --service-account tiller \
      --tiller-namespace="${var.tiller_namespace}" \
      --wait \
      --upgrade \
      --kube-context=${local.kube_context} && \
    helm repo update
SCRIPT
  }
}
