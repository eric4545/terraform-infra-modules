# FIXME: wait https://github.com/helm/charts/pull/7709 to support istio
resource "null_resource" "install_external_dns" {
  depends_on = ["null_resource.kubectl", "null_resource.install_helm"]

  triggers {
    version = "${var.external_dns_version}"
  }

  provisioner "local-exec" {
    command = <<SCRIPT
helm upgrade external-dns stable/external-dns \
  --version="${var.external_dns_version}" \
  --set provider=cloudflare \
  --set cloudflare.email="${var.cloudflare_email}" \
  --set cloudflare.apiKey="${var.cloudflare_token}" \
  --set policy=sync \
  --set rbac.create=true \
  --set sources[0]=service \
  --set sources[1]=istio-gateway \
  --set sources[2]=ingress \
  --install \
  --wait \
  --namespace="external-dns" \
  --tiller-namespace="tiller-system" \
  --kube-context="${local.kube_context}"
SCRIPT
  }
}
