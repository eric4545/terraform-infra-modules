resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true

  tags = "${
    map(
     "Name", "${var.env}",
     "env", "${var.env}",
    )
  }"
}

data "aws_availability_zones" "available" {}

locals {
  num_zones = "${length(data.aws_availability_zones.available.names)}"
}
