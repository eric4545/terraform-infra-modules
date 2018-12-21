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

variable "num_zones" {
  type    = "string"
  default = 3
}
