resource "helm_release" "cert_manager" {
  count = "${var.cert_manager_enabled}"

  name      = "cert-manager"
  chart     = "stable/cert-manager"
  namespace = "addons"
  version   = "${var.cert_manager_chart_version}"
}
