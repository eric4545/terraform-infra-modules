variable "gcp_project" {
  description = "Google cloud project for resource create in"
}

variable "cluster_name" {
  type        = "string"
  description = "Set cluster_name "
}

variable "cluster_region" {
  description = "Master GKE region"
}

variable "gitlab_token" {
  description = "GitLab personal access token"
}

variable "gitlab_project" {
  description = "GitLab project"
}

variable "git_email" {
  description = "Email to use as git committer of flux"
}

variable "git_user" {
  description = "Username to use as git committer of flux"
}

variable "tiller_namespace" {
  description = "Set an alternative Tiller namespace, here default `kube-system`"
  default     = "kube-system"
}

variable "flux_chart_version" {
  description = "flux chart version, ref: https://github.com/weaveworks/flux/blob/master/chart/flux/Chart.yaml#L5"
  default     = "0.5.1"
}
