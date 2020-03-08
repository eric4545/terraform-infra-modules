resource "helm_release" "kubernetes_dashboard" {
  count = "${var.kubernetes_dashboard_enabled}"

  name      = "kubernetes-dashboard"
  namespace = "addons"
  chart     = "stable/kubernetes-dashboard"
  version   = "${var.kubernetes_dashboard_chart_version}"

  set {
    name  = "rbac.create"
    value = true
  }

  set {
    name  = "rbac.clusterAdminRole"
    value = true
  }
}
