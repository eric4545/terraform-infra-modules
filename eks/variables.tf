variable "aws_region" {
  type        = "string"
  description = "AWS resource locate"
  default     = "ap-southeast-1"
}

variable "env" {
  type        = "string"
  description = "Set environment"
  default     = "testing"
}

variable "cluster_name" {
  type        = "string"
  description = "Set cluster_name to override"
  default     = "terraform-eks"
}

variable "worker_version" {
  type        = "string"
  description = "(Optional) Desired Kubernetes worker version. If you do not specify a value, the default version is used."
  default     = "1.11"
}

variable "office_ip" {
  type    = "string"
  default = "220.246.51.142/32"
}

variable "vpc_id" {
  type = "string"
}

variable "public_subnet_ids" {
  type = "list"
}

variable "private_subnet_ids" {
  type = "list"
}

variable "aws_cni_version" {
  type    = "string"
  default = "v1.3"
}
