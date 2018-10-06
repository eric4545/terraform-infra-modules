resource "null_resource" "install_sealed_secrets" {
  count      = "${var.sealed_secrets_enabled?1:0}"
  depends_on = ["null_resource.kubectl"]

  triggers {
    chart_version = "v${var.sealed_secrets_chart_version}"
  }

  provisioner "local-exec" {
    command = <<SCRIPT
kubectl create -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v${var.sealed_secrets_chart_version}/sealedsecret-crd.yaml && \
kubectl create -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v${var.sealed_secrets_chart_version}/controller.yaml
SCRIPT
  }
}
