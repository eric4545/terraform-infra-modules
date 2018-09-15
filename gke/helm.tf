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

resource "null_resource" "install_helm" {
  depends_on = ["null_resource.kubectl", "null_resource.helm_rbac"]

  provisioner "local-exec" {
    command = <<SCRIPT
    helm init \
    --service-account tiller \
    --tiller-namespace tiller-system \
    --wait \
    --upgrade \
    --kube-context=${local.kube_context} && \
    helm repo update
SCRIPT
  }
}
