resource "aws_vpc" "eks" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "${var.env}-eks",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "eks" {
  count = "${var.num_zones}"

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index * 32}.0/19"
  vpc_id            = "${aws_vpc.eks.id}"

  tags = "${
    map(
      "Name", "${var.env}-eks",
      "kubernetes.io/cluster/${var.cluster_name}", "shared",
      "k8s.io/cluster-autoscaler/enabled", ""
    )
  }"
}

resource "aws_internet_gateway" "eks" {
  vpc_id = "${aws_vpc.eks.id}"

  tags {
    Name = "${var.env}-eks"
  }
}

resource "aws_route_table" "eks" {
  vpc_id = "${aws_vpc.eks.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eks.id}"
  }
}

resource "aws_route_table_association" "eks" {
  count          = "${var.num_zones}"
  subnet_id      = "${aws_subnet.eks.*.id[count.index]}"
  route_table_id = "${aws_route_table.eks.id}"
}
