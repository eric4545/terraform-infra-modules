resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller-cluster-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = "system:serviceaccount:kube-system:tiller"
  }
}

# TODO: https://github.com/helm/helm/blob/master/docs/tiller_ssl.md

provider "helm" {
  version         = "~> 0.7"
  install_tiller  = true
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.12.1"
  service_account = "tiller"
  override        = ["'spec.template.spec.containers[0].command'='{/tiller,--storage=secret}'"]

  kubernetes {
    host                   = "${var.kubernetes_host}"
    cluster_ca_certificate = "${var.kubernetes_cluster_ca_certificate}"
    token                  = "${var.kubernetes_token}"
  }
}


resource "helm_repository" "incubator" {
  name  = "incubator"

  url = "https://kubernetes-charts-incubator.storage.googleapis.com/"
}
