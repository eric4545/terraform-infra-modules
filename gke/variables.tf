variable "gcp_project" {
  description = "Google cloud project for resource create in"
}

variable "gcr_project" {
  type        = "string"
  description = "Google cloud registry project, cluster may deploy in different project but sharing same GCR project"
}

variable "gcp_network" {
  type        = "string"
  description = "GCP network"
  default     = "default"
}

variable "env" {}

variable "cluster_name" {
  type        = "string"
  description = "(Optional) Set cluster_name to override"
  default     = ""
}

variable "master_region" {
  description = "Master GKE region"
  default     = "asia-east1"
}

variable "kubernetes_master_version" {
  description = "(Optional) Default latest GKE version if unset"
  default     = ""
}

variable "kubernetes_worker_version" {
  description = "(Optional) Default latest GKE version if unset"
  default     = ""
}

variable "disk_type" {
  description = "(Optional) Type of the disk attached to each node (e.g. 'pd-standard' or 'pd-ssd'). If unspecified, the default disk type is 'pd-standard'"
  default     = "pd-standard"
}

variable "preemptible" {
  description = "(Optional) A boolean that represents whether or not the underlying node VMs are preemptible. Defaults to true.[EXP]"
  default     = "true"
}

variable "stackdriver_logging_enabled" {
  description = "Enable stackdriver logging"
  type        = "string"
  default     = true
}

variable "stackdriver_monitoring_enabled" {
  description = "Enable stackdriver monitoring"
  type        = "string"
  default     = true
}

variable "http_load_balancing_enabled" {
  description = "(Optional) Enable GCLB HTTP (L7) load balancing controller addon Default: false, use istio gateway"
  type        = "string"
  default     = false
}

variable "istio_version" {
  description = "Istio version to be install"
  type        = "string"
  default     = "1.0.2"
}

variable "istio_enabled" {
  description = "Enable istio service mesh"
  default     = true
}

variable "istio_egressgateway_enabled" {
  description = "Enable istio egress gateway"
  default     = false
}

variable "cert_manager_chart_version" {
  description = "Cert manager chart version"
  type        = "string"
  default     = "0.5.0"
}

variable "cert_manager_enabled" {
  description = "Enable Cert manager"
  default     = true
}

variable "sealed_secrets_chart_version" {
  description = "Sealed secrets chart version"
  type        = "string"
  default     = "0.7.0"
}

variable "sealed_secrets_enabled" {
  description = "Enable Sealed secrets"
  default     = false
}

variable "stackdriver_adapter_version" {
  description = "custom metrics stackdriver adapter version"
  type        = "string"
  default     = "0.8.0"
}

variable "stackdriver_adapter_enabled" {
  description = "Enable custom metrics stackdriver adapter"
  default     = true
}

variable "external_dns_chart_version" {
  description = "external-dns chart version, ref: https://github.com/helm/charts/blob/master/stable/external-dns/Chart.yaml#L6"
  type        = "string"
  default     = "0.7.8"
}

variable "external_dns_enabled" {
  description = "Enable external-dns"
  default     = true
}

variable "kubernetes_dashboard_chart_version" {
  description = "kubernetes-dashboard chart version"
  type        = "string"
  default     = "0.7.3"
}

variable "kubernetes_dashboard_enabled" {
  description = "Enable kubernetes-dashboard"
  default     = true
}

variable "cloudflare_email" {
  description = "Cloudflare email for external-dns access api"
}

variable "cloudflare_token" {
  description = "Cloudflare token for external-dns access api"
}

variable "tiller_namespace" {
  description = "Install tiller into a particular namespace (default kube-system)"
  default     = "kube-system"
}
