resource "helm_release" "cluster_autoscaler" {
  count = "${var.cluster_autoscaler_enabled}"

  name      = "cluster-autoscaler"
  namespace = "kube-system"
  chart     = "stable/cluster-autoscaler"
  version   = "${var.cluster_autoscaler_chart_version}"

  set {
    name  = "autoDiscovery.clusterName"
    value = "${var.kubernetes_cluster_name}"
  }

  set {
    name  = "cloudProvider"
    value = "aws"
  }

  set {
    name  = "awsRegion"
    value = "${var.aws_region}"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "sslCertPath"
    value = "/etc/kubernetes/pki/ca.crt"
  }
}

# TODO: https://github.com/helm/charts/tree/master/stable/cluster-autoscaler#iam Set IAM to worker

