variable "gcp_project" {}

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

variable "logging_enabled" {
  description = "Enable stackdriver logging"
  type        = "string"
  default     = true
}

variable "monitoring_enabled" {
  description = "Enable stackdriver monitoring"
  type        = "string"
  default     = true
}

variable "istio_version" {
  description = "Istio version to be install"
  type        = "string"
  default     = "1.0.2"
}

variable "cert_manager_version" {
  description = "Cert manager chart version"
  type        = "string"
  default     = "0.4.1"
}

variable "stackdriver_adapter_version" {
  description = "custom metrics stackdriver adapter version"
  type        = "string"
  default     = "0.8.0"
}
variable "external_dns_version" {
  description = "external-dns chart version"
  type        = "string"
  default     = "0.7.5"
}
variable "kubernetes_dashboard_version" {
  description = "kubernetes-dashboard chart version"
  type        = "string"
  default     = "0.7.3"
}
variable "cloudflare_email" {
  description = "Cloudflare email for external-ens access api"
}

variable "cloudflare_token" {
  description = "Cloudflare token for external-ens access api"
}