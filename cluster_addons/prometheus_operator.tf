resource "helm_release" "prometheus_operator" {
  # count = "${var.node_problem_detector_enabled?1:0}"

  name      = "prometheus-operator"
  # TODO: Change to monitoring
  namespace = "kube-system"
  chart     = "stable/prometheus-operator"
  # version   = "${var.node_problem_detector_chart_version}"
}
