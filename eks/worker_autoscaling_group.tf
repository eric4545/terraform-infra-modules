resource "aws_autoscaling_group" "worker" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.worker.id}"
  max_size             = 2
  min_size             = 1
  name                 = "${var.env}-eks"
  vpc_zone_identifier  = ["${aws_subnet.eks.*.id}"]

  tag {
    key                 = "Name"
    value               = "${var.env}-eks"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = ""
    propagate_at_launch = true
  }
}
