# FIXME: wait https://github.com/helm/charts/pull/7709 to support istio
resource "null_resource" "install_external_dns" {
  count      = "${var.external_dns_enabled?0:1}"
  depends_on = ["null_resource.kubectl", "null_resource.install_helm"]

  triggers {
    version = "${var.external_dns_chart_version}"
  }

  provisioner "local-exec" {
    command = <<SCRIPT
helm upgrade external-dns stable/external-dns \
  --version="${var.external_dns_chart_version}" \
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

resource "null_resource" "external_dns_cluster_issuer" {
  count      = "${var.external_dns_enabled?0:1}"
  depends_on = ["null_resource.kubectl", "null_resource.install_external_dns"]

  provisioner "local-exec" {
    command = <<SCRIPT
cat <<EOF | kubectl --context="${local.kube_context}" -n cert-manager apply -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-key
data:
  api-key: ${base64encode(var.cloudflare_token)}
  email: ${base64encode(var.cloudflare_email)}
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ${var.cloudflare_email}
    privateKeySecretRef:
      name: letsencrypt-staging
    dns01:
      providers:
        - name: cf-dns
          cloudflare:
            email: ${var.cloudflare_email}
            apiKeySecretRef:
              name: cloudflare-api-key
              key: api-key
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${var.cloudflare_email}
    privateKeySecretRef:
      name: letsencrypt-prod
    dns01:
      providers:
        - name: cf-dns
          cloudflare:
            email: ${var.cloudflare_email}
            apiKeySecretRef:
              name: cloudflare-api-key
              key: api-key
EOF
SCRIPT
  }
}
