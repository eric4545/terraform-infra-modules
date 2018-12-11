data "google_container_engine_versions" "cluster_region" {
  zone = "${var.cluster_region}"
}

locals {
  # EG: testing--cluster
  default_cluster_name = "${var.env}-${var.cluster_region}-cluster"
  subnetwork_name      = "${local.cluster_name}-subnet"

  # Use to override default_cluster_name
  cluster_name              = "${var.cluster_name!=""?var.cluster_name:local.default_cluster_name}"
  kubernetes_master_version = "${var.kubernetes_master_version!=""?var.kubernetes_master_version:data.google_container_engine_versions.cluster_region.latest_node_version}"
  kubernetes_worker_version = "${var.kubernetes_worker_version!=""?var.kubernetes_worker_version:data.google_container_engine_versions.cluster_region.latest_node_version}"

  kube_context = "gke_${var.gcp_project}_${var.cluster_region}_${local.cluster_name}"
}

# https://www.terraform.io/docs/providers/google/r/container_cluster.html
resource "google_container_cluster" "primary" {
  name               = "${local.cluster_name}"
  min_master_version = "${local.kubernetes_master_version}"
  region             = "${var.cluster_region}"

  # TODO: allow change network
  network                  = "projects/${var.gcp_project}/global/networks/${var.gcp_network}"
  monitoring_service       = "${var.stackdriver_monitoring_enabled?"monitoring.googleapis.com/kubernetes":"none"}"
  logging_service          = "${var.stackdriver_logging_enabled?"logging.googleapis.com/kubernetes":"none"}"
  remove_default_node_pool = "false"

  master_auth {
    # https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#disable_basic_auth
    username = ""
    password = ""

    client_certificate_config {
      # https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#restrict_authn_methods
      issue_client_certificate = false
    }
  }

  # Set the default-pool to 0, faster creation, will not use default-pool
  node_pool {
    name       = "default-pool"
    node_count = 0

    node_config {
      preemptible     = "${var.preemptible}"
      disk_type       = "${var.disk_type}"
      service_account = "${google_service_account.gke_node.email}"
      image_type      = "${var.image_type}"

      labels {
        env        = "${var.env}"
        managed_by = "terraform"
      }

      workload_metadata_config {
        node_metadata = "SECURE"
      }
    }
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = "${var.horizontal_pod_autoscaling_enabled?false:true}"
    }

    http_load_balancing {
      disabled = "${var.http_load_balancing_enabled?false:true}"
    }

    kubernetes_dashboard {
      disabled = true
    }

    network_policy_config {
      disabled = "${var.network_policy_enabled?false:true}"
    }
  }

  # master_authorized_networks_config {
  #   cidr_blocks = "${authorized}"
  # }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
  resource_labels {
    env = "${var.env}"
  }
  # enable VPC native
  ip_allocation_policy {
    create_subnetwork = true

    subnetwork_name = "${local.subnetwork_name}"
  }
  # enable network policy
  network_policy {
    enabled = "${var.network_policy_enabled}"
  }
  lifecycle {
    # ignore_changes node_pool otherwise it detect no default-pool will recreate cluster
    ignore_changes = ["node_pool"]
  }
}

data "google_client_config" "default" {}

data "google_container_cluster" "primary" {
  name   = "${local.cluster_name}"
  region = "${var.cluster_region}"
}

provider "kubernetes" {
  version          = "~> 1.4"
  load_config_file = false

  host                   = "https://${data.google_container_cluster.primary.endpoint}"
  token                  = "${data.google_client_config.default.access_token}"
  cluster_ca_certificate = "${base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
}

resource "null_resource" "kubectl" {
  depends_on = ["google_container_cluster.primary", "google_container_node_pool.n2_pool"]

  triggers = {
    # A hack to run everytime
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "gcloud --project=${var.gcp_project} container clusters get-credentials ${local.cluster_name} --region=${var.cluster_region}"
  }
}

resource "null_resource" "k8s_cluster_admin" {
  depends_on = ["null_resource.kubectl"]

  provisioner "local-exec" {
    command = "kubectl --context=\"${local.kube_context}\" create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)"
  }
}
