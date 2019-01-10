resource "helm_release" "node_problem_detector" {
  count = "${var.node_problem_detector_enabled?1:0}"

  name      = "node-problem-detector"
  namespace = "kube-system"
  chart     = "stable/node-problem-detector"
  version   = "${var.node_problem_detector_chart_version}"
}
