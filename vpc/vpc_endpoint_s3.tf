resource "aws_vpc_endpoint" "ap_southeast_1_s3" {
  vpc_id       = "${aws_vpc.main.id}"
  service_name = "com.amazonaws.ap-southeast-1.s3"
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count           = "${local.num_zones}"
  vpc_endpoint_id = "${aws_vpc_endpoint.ap_southeast_1_s3.id}"
  route_table_id  = "${element(aws_route_table.public.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count           = "${local.num_zones}"
  vpc_endpoint_id = "${aws_vpc_endpoint.ap_southeast_1_s3.id}"
  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}
