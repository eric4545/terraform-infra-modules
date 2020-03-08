resource "aws_eks_cluster" "primary" {
  name     = "${var.cluster_name}"
  role_arn = "${aws_iam_role.eks_admin_role.arn}"
  version  = "${var.master_version}"

  vpc_config {
    security_group_ids = ["${aws_security_group.master.id}"]
    subnet_ids         = ["${var.public_subnet_ids}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.cluster_policy",
    "aws_iam_role_policy_attachment.service_policy",
  ]
}

data "external" "aws_iam_authenticator" {
  program = ["sh", "-c", "aws-iam-authenticator token -i ${var.cluster_name} | jq -r -c .status"]
}

resource "null_resource" "kubectl" {
  depends_on = ["aws_eks_cluster.primary"]

  triggers = {
    # A hack to run everytime
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.cluster_name}"
  }
}

provider "kubernetes" {
  version                = "~> 1.4"
  host                   = "${aws_eks_cluster.primary.endpoint}"
  cluster_ca_certificate = "${base64decode(aws_eks_cluster.primary.certificate_authority.0.data)}"
  token                  = "${data.external.aws_iam_authenticator.result.token}"
  load_config_file       = false
}

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.primary.endpoint}
    certificate-authority-data: ${aws_eks_cluster.primary.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster_name}"
      # env:
        # - name: AWS_PROFILE
        #   value: "<aws-profile>"
KUBECONFIG
}
