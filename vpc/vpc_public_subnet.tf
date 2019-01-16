resource "aws_subnet" "public" {
  count = "${local.num_zones}"

  availability_zone = "${element(data.aws_availability_zones.available.names,count.index)}"
  cidr_block        = "${cidrsubnet(var.cidr_block,4,(count.index+1)*2)}"
  vpc_id            = "${aws_vpc.main.id}"

  tags = "${
    map(
      "Name", "${var.env}",
      "env", "${var.env}",
      "k8s.io/cluster-autoscaler/enabled", "",
      "kubernetes.io/cluster/${var.eks_cluster_name}", "shared"
    )
  }"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${local.num_zones}"
  subnet_id      = "${aws_subnet.public.*.id[count.index]}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_egress_only_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
}
