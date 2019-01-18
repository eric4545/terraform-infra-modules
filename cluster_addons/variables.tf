variable "kubernetes_host" {}
variable "kubernetes_cluster_ca_certificate" {}
variable "kubernetes_token" {}
variable "kubernetes_cluster_name" {}

variable "istio_chart_version" {
  description = "Istio version to be install, Ref tag: https://github.com/istio/istio/releases"
  type        = "string"
  default     = "1.1.0"
}

variable "istio_version" {
  description = "Istio version to be install, Ref tag: https://github.com/istio/istio/releases"
  type        = "string"
  default     = "1.0.5"
}

variable "istio_enabled" {
  description = "Enable istio service mesh"
  default     = true
}

variable "istio_egressgateway_enabled" {
  type        = "string"
  description = "Enable istio egress gateway"
  default     = "false"
}

variable "cluster_autoscaler_chart_version" {
  description = "Cert manager chart version, ref: https://github.com/helm/charts/blob/master/stable/cluster-autoscaler/Chart.yaml#L5"
  type        = "string"
  default     = "0.11.0"
}

variable "cluster_autoscaler_enabled" {
  description = "Enable Cluster Autoscaler"
  default     = true
}

variable "cert_manager_chart_version" {
  description = "Cert manager chart version, ref: https://github.com/helm/charts/blob/master/stable/cert-manager/Chart.yaml#L2"
  type        = "string"
  default     = "v0.5.2"
}

variable "cert_manager_enabled" {
  description = "Enable Cert manager"
  default     = true
}
variable "kubernetes_dashboard_chart_version" {
  description = "kubernetes-dashboard chart version, ref: https://github.com/helm/charts/blob/master/stable/kubernetes-dashboard/Chart.yaml#L2"
  type        = "string"
  default     = "0.8.0"
}

variable "kubernetes_dashboard_enabled" {
  description = "Enable kubernetes-dashboard"
  default     = true
}

variable "tiller_namespace" {
  description = "Install tiller into a particular namespace (default kube-system)"
  default     = "kube-system"
}

variable "chaoskube_chart_version" {
  description = "chaoskube chart version, ref: https://github.com/helm/charts/blob/master/stable/chaoskube/Chart.yaml#L3"
  type        = "string"
  default     = "0.10.0"
}

variable "chaoskube_enabled" {
  description = "Enable chaoskube, default: false"
  default     = false
}

variable "metrics_server_chart_version" {
  description = "metrics-server chart version, ref: https://github.com/helm/charts/blob/master/stable/metrics-server/Chart.yaml#L5"
  type        = "string"
  default     = "2.0.4"
}

variable "metrics_server_enabled" {
  description = "Enable metrics-server, default: true"
  default     = true
}

variable "node_problem_detector_chart_version" {
  description = "node-problem-detector chart version, ref: https://github.com/helm/charts/blob/master/stable/node-problem-detector/Chart.yaml#L2"
  type        = "string"
  default     = "1.1.0"
}

variable "node_problem_detector_enabled" {
  description = "Enable node-problem-detector, default: true"
  default     = false
}

variable "external_dns_chart_version" {
  description = "external-dns chart version, ref: https://github.com/helm/charts/blob/master/stable/external-dns/Chart.yaml#L6"
  type        = "string"
  default     = "1.3.0"
}

variable "external_dns_enabled" {
  description = "Enable external-dns"
  default     = true
}

variable "external_dns_chartlog_level" {
  description = "Verbosity of the External DNS logs (options: panic, debug, info, warn, error, fatal)"
  default     = "info"
}

variable "aws_region" {
  description = "AWS region for external-dns manage route53"
  default     = ""
}

variable "kube_spot_termination_notice_handler_chart_version" {
  description = "kube-spot-termination-notice-handler chart version, ref: https://github.com/helm/charts/blob/master/incubator/kube-spot-termination-notice-handler/Chart.yaml#L4"
  type        = "string"
  default     = "0.4.0"
}

variable "kube_spot_termination_notice_handler_enabled" {
  description = "Enable kube-spot-termination-notice-handler"
  default     = true
}
