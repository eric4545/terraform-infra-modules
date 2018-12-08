resource "helm_release" "cert_manager" {
  count      = "${var.cert_manager_enabled?1:0}"
  depends_on = ["null_resource.kubectl", "null_resource.install_helm"]

  name  = "cert-manager"
  chart = "stable/cert-manager"

  namespace = "cert-manager"
  version   = "v${var.cert_manager_chart_version}"
}
