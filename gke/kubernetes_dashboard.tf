resource "helm_release" "kubernetes_dashboard" {
  count      = "${var.kubernetes_dashboard_enabled?1:0}"
  depends_on = ["null_resource.kubectl", "null_resource.install_helm", "helm_release.istio"]

  name  = "kubernetes-dashboard"
  chart = "stable/kubernetes-dashboard"

  namespace = "kubernetes-dashboard"
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
