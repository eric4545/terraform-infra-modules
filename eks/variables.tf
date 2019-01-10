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

variable "version" {
  type        = "string"
  description = "(Optional) Desired Kubernetes master version. If you do not specify a value, the latest available version is used."
  default     = ""
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
