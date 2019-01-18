resource "aws_subnet" "private" {
  count = "${local.num_zones}"

  availability_zone = "${element(data.aws_availability_zones.available.names,count.index)}"
  cidr_block        = "${cidrsubnet(var.cidr_block,4,(count.index+0.5)*2)}"
  vpc_id            = "${aws_vpc.main.id}"

  tags = "${
    map(
      "Name", "${var.env}",
      "env", "${var.env}",
      "kubernetes.io/role/internal-elb","1"
    )
  }"
}

resource "aws_route_table" "private" {
  count  = "${local.num_zones}"
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${local.num_zones}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
