resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data {
    mapRoles = <<YAML
- rolearn: ${aws_iam_role.worker_role.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
YAML
  }
}

data "aws_ami" "eks_worker" {
  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID

  filter {
    name   = "name"
    values = ["amazon-eks-node-*"]
  }
}

# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_region" "current" {}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml
locals {
  node_user_data = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh \
  --apiserver-endpoint '${aws_eks_cluster.primary.endpoint}' \
  --b64-cluster-ca '${aws_eks_cluster.primary.certificate_authority.0.data}' \
  '${var.cluster_name}'
USERDATA
}

resource "aws_launch_configuration" "worker" {
  name_prefix                 = "${var.env}-eks"
  iam_instance_profile        = "${aws_iam_instance_profile.worker.name}"
  image_id                    = "${data.aws_ami.eks_worker.id}"
  instance_type               = "m5.large"                                # TODO: Allow change worker instance_type
  security_groups             = ["${aws_security_group.worker.id}"]
  user_data_base64            = "${base64encode(local.node_user_data)}"
  spot_price                  = "0.05"
  associate_public_ip_address = true
  key_name                    = "${aws_key_pair.debugger.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}
