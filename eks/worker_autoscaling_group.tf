resource "aws_autoscaling_group" "worker" {
  desired_capacity     = 3
  launch_configuration = "${aws_launch_configuration.worker.id}"
  max_size             = 6
  min_size             = 3
  name                 = "${var.env}-eks"
  vpc_zone_identifier  = ["${var.private_subnet_ids}"]

  tag {
    key                 = "Name"
    value               = "${var.env}-eks"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = ""
    propagate_at_launch = true
  }
}
