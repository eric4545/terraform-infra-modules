resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.env}"
  }
}

resource "aws_eip" "nat_ip" {
  count = "${local.num_zones}"

  vpc = true
}

resource "aws_nat_gateway" "nat" {
  count = "${local.num_zones}"

  allocation_id = "${element(aws_eip.nat_ip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
}
