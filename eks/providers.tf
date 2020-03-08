provider "aws" {
  version = "~> 1.53"
  region  = "${var.aws_region}"
}

provider "external" {
  version = "~> 1.0"
}
