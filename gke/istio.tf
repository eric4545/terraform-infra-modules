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
  --set servicegraph.enabled=true \
  --set tracing.enabled=true \
  --set kiali.enabled=true \
  --set grafana.enabled=true \
  --set global.proxy.includeIPRanges="${data.external.ipv4_cidr.result.clusterIpv4Cidr}\,${data.external.ipv4_cidr.result.servicesIpv4Cidr}" \
  --set gateways.istio-ingressgateway.loadBalancerIP="${google_compute_address.istio_lb.address}" \
  --set gateways.istio-egressgateway.enabled=${var.istio_egressgateway_enabled} \
  --namespace=istio-system \
  --tiller-namespace=tiller-system \
  --kube-context=${local.kube_context}
SCRIPT
  }
}
