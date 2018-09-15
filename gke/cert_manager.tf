resource "null_resource" "install_cert_manager" {
  depends_on = ["null_resource.kubectl", "null_resource.install_helm"]

  triggers {
    version = "${var.cert_manager_version}"
  }

  provisioner "local-exec" {
    command = <<SCRIPT
helm upgrade cert-manager stable/cert-manager \
  --version="v${var.cert_manager_version}" \
  --install \
  --wait \
  --namespace="cert-manager" \
  --tiller-namespace="tiller-system" \
  --kube-context="${local.kube_context}"
SCRIPT
  }
}
