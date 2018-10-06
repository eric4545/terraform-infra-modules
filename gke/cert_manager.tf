resource "null_resource" "install_cert_manager" {
  count      = "${var.cert_manager_enabled?1:0}"
  depends_on = ["null_resource.kubectl", "null_resource.install_helm"]

  triggers {
    chart_version = "${var.cert_manager_chart_version}"
  }

  provisioner "local-exec" {
    command = <<SCRIPT
helm upgrade cert-manager stable/cert-manager \
  --version="v${var.cert_manager_chart_version}" \
  --install \
  --wait \
  --namespace="cert-manager" \
  --tiller-namespace="${var.tiller_namespace}" \
  --kube-context="${local.kube_context}"
SCRIPT
  }
}
