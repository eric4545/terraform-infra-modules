resource "helm_release" "external_dns" {
  count      = "${var.external_dns_enabled?1:0}"
  depends_on = ["null_resource.kubectl", "null_resource.install_helm"]

  name  = "external-dns"
  chart = "stable/external-dns"

  namespace = "external-dns"
  version   = "v${var.external_dns_chart_version}"

  set {
    name  = "provider"
    value = "cloudflare"
  }

  set {
    name  = "cloudflare.email"
    value = "${var.cloudflare_email}"
  }

  set {
    name  = "cloudflare.apiKey"
    value = "${var.cloudflare_api_key}"
  }

  set {
    name  = "policy"
    value = "sync"
  }

  set {
    name  = "rbac.create"
    value = true
  }

  # set {
  #   name  = "sources[0]"
  #   value = "service"
  # }

  set {
    name  = "sources[0]"
    value = "istio-gateway"
  }

  # set {
  #   name  = "sources[2]"
  #   value = "ingress"
  # }

  set {
    name  = "extraArgs.cloudflare-proxied"
    value = ""
  }

  set {
    name  = "txtPrefix"
    value = "${local.cluster_name}"
  }
  set {
    name  = "logLevel"
    value = "${var.external_dns_chartlog_level}"
  }
}

resource "null_resource" "external_dns_cluster_issuer" {
  count      = "${var.external_dns_enabled?1:0}"
  depends_on = ["null_resource.kubectl", "helm_release.external_dns", "null_resource.install_istio"]

  provisioner "local-exec" {
    command = <<SCRIPT
cat <<EOF | kubectl --context="${local.kube_context}" -n cert-manager apply -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-key
data:
  api-key: ${base64encode(var.cloudflare_api_key)}
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
