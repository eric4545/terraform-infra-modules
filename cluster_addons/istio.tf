resource "null_resource" "install_istio" {
  count = "${var.istio_enabled}"

  triggers = {
    version = "${var.istio_version}"
  }

  provisioner "local-exec" {
    command = <<SCRIPT
mkdir -p /tmp/${var.kubernetes_cluster_name}/istio-release && \
curl -sL https://github.com/istio/istio/releases/download/${var.istio_version}/istio-${var.istio_version}-linux.tar.gz | \
tar xz -C /tmp/${var.kubernetes_cluster_name}/istio-release && \
helm upgrade istio /tmp/${var.kubernetes_cluster_name}/istio-release/istio-${var.istio_version}/install/kubernetes/helm/istio \
  --install \
  --wait \
  --set tracing.enabled=true \
  --set kiali.enabled=true \
  --set grafana.enabled=true \
  --set global.proxy.includeIPRanges="10.0.0.1/16\,172.20.0.0/16" \
  --set gateways.istio-ingressgateway.replicaCount=2 \
  --set gateways.istio-ingressgateway.autoscaleMin=2 \
  --set gateways.istio-ingressgateway.externalTrafficPolicy=Local \
  --set gateways.istio-ingressgateway.serviceAnnotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"=nlb \
  --set gateways.istio-egressgateway.enabled=${var.istio_egressgateway_enabled} \
  --namespace=istio-system
SCRIPT
  }
}

resource "tls_private_key" "ingressgateway_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ingressgateway_self_sign_cert" {
  key_algorithm         = "${tls_private_key.ingressgateway_private_key.algorithm}"
  private_key_pem       = "${tls_private_key.ingressgateway_private_key.private_key_pem}"
  validity_period_hours = 3650

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 3

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  subject {
    common_name  = "example.com"
    organization = "null or Undefined Inc"
  }
}

resource "kubernetes_secret" "istio_cert" {
  metadata {
    name      = "istio-ingressgateway-certs"
    namespace = "istio-system"
  }

  data {
    tls.crt = "${tls_self_signed_cert.ingressgateway_self_sign_cert.cert_pem}"
    tls.key = "${tls_private_key.ingressgateway_private_key.private_key_pem}"
  }

  type = "kubernetes.io/tls"
}
