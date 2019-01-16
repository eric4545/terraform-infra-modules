resource "helm_release" "external_dns" {
  count      = "${var.external_dns_enabled?1:0}"

  name      = "external-dns"
  chart     = "stable/external-dns"
  namespace = "addons"
  version   = "v${var.external_dns_chart_version}"

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "aws.region"
    value = "${var.aws_region}"
  }
  set {
    name  = "aws.zoneType"
    value = "public"
  }

  set {
    name  = "policy"
    value = "sync"
  }

  set {
    name  = "rbac.create"
    value = true
  }

  set {
    name  = "sources[0]"
    value = "istio-gateway"
  }

#   set {
#     name  = "txtPrefix"
#     value = "${var.cluster_name}"
#   }

#   set {
#     name  = "txtOwnerId"
#     value = "${var.cluster_name}"
#   }

  set {
    name  = "logLevel"
    value = "${var.external_dns_chartlog_level}"
  }
}
