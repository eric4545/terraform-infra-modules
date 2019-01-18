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
    values = ["amazon-eks-node-${var.worker_version}-*"]
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

resource "tls_private_key" "debugger" {
  algorithm   = "RSA"
  ecdsa_curve = "4096"
}

resource "aws_key_pair" "debugger" {
  key_name   = "debugger-key"
  public_key = "${tls_private_key.debugger.public_key_openssh }"
}

resource "aws_launch_configuration" "worker" {
  name_prefix                 = "${var.env}-eks-worker"
  iam_instance_profile        = "${aws_iam_instance_profile.worker.name}"
  image_id                    = "${data.aws_ami.eks_worker.id}"
  instance_type               = "t3.large"                                # TODO: Allow change worker instance_type
  security_groups             = ["${aws_security_group.worker.id}"]
  user_data_base64            = "${base64encode(local.node_user_data)}"
  spot_price                  = "0.05"
  associate_public_ip_address = false
  key_name                    = "${aws_key_pair.debugger.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "install_aws_vpc_cni" {
  triggers = {
    version = "${var.aws_cni_version}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/${var.aws_cni_version}/aws-k8s-cni.yaml"
  }
}
