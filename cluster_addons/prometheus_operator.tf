resource "helm_release" "prometheus_operator" {
  # count = "${var.prometheus_operator_enabled}"

  name      = "prometheus-operator"
  # TODO: Change to monitoring
  namespace = "kube-system"
  chart     = "stable/prometheus-operator"
  # version   = "${var.prometheus_operator_chart_version}"
}
