# kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)

resource "null_resource" "install_stackdriver_adapter" {
  depends_on = ["null_resource.kubectl"]

  triggers {
    version = "${var.stackdriver_adapter_version}"
  }

  provisioner "local-exec" {
    command = <<SCRIPT
kubectl --context="${local.kube_context}" apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/k8s-stackdriver/custom-metrics-stackdriver-adapter-v${var.stackdriver_adapter_version}/custom-metrics-stackdriver-adapter/deploy/production/adapter.yaml
SCRIPT
  }
}
