resource "aws_iam_policy" "nlb_policy" {
  name        = "nlb-policy"
  path        = "/"
  description = "In order to provision network load balancer."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
   {
      "Sid": "kopsK8sNLBMasterPermsRestrictive",
      "Effect": "Allow",
      "Action": [
          "ec2:DescribeVpcs",
          "ec2:CreateSecurityGroup",
          "elasticloadbalancing:*"
      ],
      "Resource": [
          "*"
      ]
  }
  ]
}
EOF
}

resource "aws_iam_role" "eks_admin_role" {
  name = "eks-admin-role"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["sts:AssumeRole"],
            "Principal": {
              "Service": "eks.amazonaws.com"
            }
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "nlb_policy" {
  policy_arn = "${aws_iam_policy.nlb_policy.arn}"
  role       = "${aws_iam_role.eks_admin_role.name}"
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks_admin_role.name}"
}

resource "aws_iam_role_policy_attachment" "service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks_admin_role.name}"
}
