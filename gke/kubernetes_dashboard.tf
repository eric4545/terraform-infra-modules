resource "null_resource" "install_kubernetes_dashboard" {
  count      = "${var.kubernetes_dashboard_enabled?1:0}"
  depends_on = ["null_resource.kubectl", "null_resource.install_helm"]

  triggers {
    version = "${var.kubernetes_dashboard_chart_version}"
  }

  provisioner "local-exec" {
    # TODO: Should only enable clusterAdminRole in dev, disable in production/testing
    command = <<SCRIPT
helm upgrade kubernetes-dashboard stable/kubernetes-dashboard \
  --version="${var.kubernetes_dashboard_chart_version}" \
  --set rbac.create=true \
  --set rbac.clusterAdminRole=true \
  --install \
  --wait \
  --namespace="kubernetes-dashboard" \
  --tiller-namespace="${var.tiller_namespace}" \
  --kube-context="${local.kube_context}"
SCRIPT
  }
}
