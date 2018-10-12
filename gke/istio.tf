# HACK: get gke cluster and services ipv4 range for istio only handle those ip range egress
data "external" "ipv4_cidr" {
  depends_on = ["google_container_cluster.primary"]

  program = ["/bin/sh", "-c",
    <<SCRIPT
gcloud --project=${var.gcp_project} container clusters describe ${local.cluster_name} \
  --region=${var.master_region} \
  --format=json | jq '{clusterIpv4Cidr ,servicesIpv4Cidr}'
SCRIPT
    ,
  ]
}

resource "google_compute_address" "istio_lb" {
  count        = "${var.istio_enabled?1:0}"
  name         = "${local.cluster_name}-istio-gateway-address"
  address_type = "EXTERNAL"
  region       = "${var.master_region}"
}

resource "null_resource" "install_istio" {
  count      = "${var.istio_enabled?1:0}"
  depends_on = ["null_resource.kubectl", "null_resource.install_helm"]

  triggers = {
    version = "${var.istio_version}"
  }

  provisioner "local-exec" {
    command = <<SCRIPT
mkdir -p /tmp/${local.cluster_name}/istio-release && \
curl -sL https://github.com/istio/istio/releases/download/${var.istio_version}/istio-${var.istio_version}-linux.tar.gz | tar xz -C /tmp/${local.cluster_name}/istio-release && \
helm upgrade istio /tmp/${local.cluster_name}/istio-release/istio-${var.istio_version}/install/kubernetes/helm/istio \
  --install \
  --wait \
  --set servicegraph.enabled=false \
  --set tracing.enabled=true \
  --set kiali.enabled=true \
  --set grafana.enabled=true \
  --set global.proxy.includeIPRanges="${data.external.ipv4_cidr.result.clusterIpv4Cidr}\,${data.external.ipv4_cidr.result.servicesIpv4Cidr}" \
  --set gateways.istio-ingressgateway.loadBalancerIP="${google_compute_address.istio_lb.address}" \
  --set gateways.istio-egressgateway.enabled=${var.istio_egressgateway_enabled} \
  --namespace=istio-system \
  --tiller-namespace="${var.tiller_namespace}" \
  --kube-context=${local.kube_context}
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

resource "null_resource" "install_istio_ingressgateway_certs" {
  depends_on = ["null_resource.kubectl", "null_resource.install_istio"]

  triggers {
    validity_start_time = "${tls_self_signed_cert.ingressgateway_self_sign_cert.validity_start_time}"
    validity_end_time   = "${tls_self_signed_cert.ingressgateway_self_sign_cert.validity_end_time}"
  }

  provisioner "local-exec" {
    command = <<SCRIPT
cat <<EOF | kubectl --context="${local.kube_context}" apply --namespace=istio-system -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: istio-ingressgateway-certs
type: kubernetes.io/tls
data:
  tls.crt: "${base64encode(tls_self_signed_cert.ingressgateway_self_sign_cert.cert_pem)}"
  tls.key: "${base64encode(tls_private_key.ingressgateway_private_key.private_key_pem)}"
EOF
SCRIPT
  }
}
