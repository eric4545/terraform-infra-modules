resource "null_resource" "install_chaoskube" {
  count      = "${var.chaoskube_enabled?1:0}"
  depends_on = ["null_resource.kubectl", "null_resource.install_helm"]

  triggers {
    chart_version = "${var.chaoskube_chart_version}"
  }

  provisioner "local-exec" {
    command = <<SCRIPT
helm upgrade chaoskube stable/chaoskube \
  --version="${var.chaoskube_chart_version}" \
  --set dryRun=false \
  --set labels="stage!=production" \
  --set namespaces="!kube-system\,!production" \
  --set annotations="chaos.alpha.kubernetes.io/enabled=true" \
  --set excludedWeekdays="Sat\,Sun" \
  --install \
  --wait \
  --namespace="chaoskube" \
  --tiller-namespace="${var.tiller_namespace}" \
  --kube-context="${local.kube_context}"
SCRIPT
  }
}
