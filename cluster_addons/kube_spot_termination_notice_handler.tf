resource "helm_release" "kube_spot_termination_notice_handler" {
  count = "${var.kube_spot_termination_notice_handler_enabled}"

  name       = "kube-spot-termination-notice-handler"
  namespace  = "kube-system"
  repository = "${helm_repository.incubator.metadata.0.name}"
  chart      = "kube-spot-termination-notice-handler"
  version    = "${var.kube_spot_termination_notice_handler_chart_version}"
}
