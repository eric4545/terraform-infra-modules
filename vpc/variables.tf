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

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "office_ip" {
  type    = "string"
  default = "220.246.51.142/32"
}

# variable "vpc_tags" {}

# variable "eks_cluster_names" {
#   type        = "list"
#   description = "List of EKS cluster name to tag vpc"
# }
