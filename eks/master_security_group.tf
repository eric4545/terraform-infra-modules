resource "aws_security_group" "master" {
  name        = "${var.env}-eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "${var.env}-eks",
     "kubernetes.io/cluster/${var.cluster_name}", "owned",
    )
  }"
}

# OPTIONAL: Allow inbound traffic from your local workstation external IP
#           to the Kubernetes. You will need to replace A.B.C.D below with
#           your real IP. Services like icanhazip.com can help you find this.
resource "aws_security_group_rule" "office_to_master_https" {
  cidr_blocks       = ["${var.office_ip}"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.master.id}"
  to_port           = 443
  type              = "ingress"
}
resource "aws_security_group_rule" "office_to_worker_ssh" {
  cidr_blocks       = ["${var.office_ip}"]
  description       = "Allow workstation to ssh to the worker"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.worker.id}"
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "master_from_worker" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.worker.id}"
  to_port                  = 443
  type                     = "ingress"
}