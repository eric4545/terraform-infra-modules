resource "helm_release" "chaoskube" {
  count      = "${var.chaoskube_enabled?1:0}"
  depends_on = ["null_resource.kubectl", "null_resource.install_helm"]

  name  = "chaoskube"
  chart = "stable/chaoskube"

  namespace = "chaoskube"
  version   = "v${var.chaoskube_chart_version}"

  set {
    name  = "dryRun"
    value = false
  }

  set {
    name  = "labels"
    value = "stage!=production"
  }

  set {
    name  = "namespaces"
    value = "!kube-system\\,!production"
  }

  set {
    name  = "annotations"
    value = "chaos.alpha.kubernetes.io/enabled=true"
  }

  set {
    name  = "excludedWeekdays"
    value = "Sat\\,Sun"
  }

  set {
    name  = "rbac.create"
    value = true
  }
}
