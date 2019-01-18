resource "helm_release" "metrics_server" {
  count = "${var.metrics_server_enabled}"

  name      = "metrics-server"
  namespace = "kube-system"
  chart     = "stable/metrics-server"
  version   = "${var.metrics_server_chart_version}"

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }
}
