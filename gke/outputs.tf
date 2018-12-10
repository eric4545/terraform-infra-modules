# The following outputs allow authentication and connectivity to the GKE Cluster.
# Are those secure to use
output "endpoint" {
  value = "${google_container_cluster.primary.endpoint}"
}
output "cluster_name" {
  value = "${local.cluster_name}"
}

output "client_certificate" {
  sensitive = true
  value     = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
}

output "client_key" {
  sensitive = true
  value     = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
}

output "cluster_ca_certificate" {
  sensitive = true
  value     = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
}

output "gcr_key" {
  sensitive   = true
  description = "GCR service account private key"
  value       = "${base64decode(google_service_account_key.gcr_viewer.private_key)}"
}

output "gcr_docker_config" {
  sensitive   = true
  description = "GCR docker pull secret"
  value       = "${jsonencode(local.gcr_dockercfg)}"
}

output "lb_address" {
  description = "Istio LB IP Address"
  value       = "${var.istio_enabled?google_compute_address.istio_lb.0.address:""}"
}

output "kube_context" {
  description = "kubectl context"
  value       = "${local.kube_context}"
}

output "tiller_namespace" {
  description = "helm tiller namespace"
  value       = "tiller-namespace"
}
