data "google_container_engine_versions" "master_region" {
  zone = "${var.master_region}"
}

locals {
  # EG: testing--cluster
  default_cluster_name = "${var.env}-${var.master_region}-cluster"

  # Use to override default_cluster_name
  cluster_name              = "${var.cluster_name!=""?var.cluster_name:local.default_cluster_name}"
  kubernetes_master_version = "${var.kubernetes_master_version!=""?var.kubernetes_master_version:data.google_container_engine_versions.master_region.latest_node_version}"
  kubernetes_worker_version = "${var.kubernetes_worker_version!=""?var.kubernetes_worker_version:data.google_container_engine_versions.master_region.latest_node_version}"

  kube_context = "gke_${var.gcp_project}_${var.master_region}_${local.cluster_name}"

  horizontal_pod_autoscaling_disabled = "${var.horizontal_pod_autoscaling_enabled?false:true}"
  http_load_balancing_disabled        = "${var.http_load_balancing_enabled?false:true}"

  # authorized = {
  #   # cidr_block   = ""
  #   # display_name = ""
  # }
}

# https://www.terraform.io/docs/providers/google/r/container_cluster.html
resource "google_container_cluster" "primary" {
  name               = "${local.cluster_name}"
  min_master_version = "${local.kubernetes_master_version}"
  region             = "${var.master_region}"

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
      disabled = "${local.horizontal_pod_autoscaling_disabled}"
    }

    http_load_balancing {
      disabled = "${local.http_load_balancing_disabled}"
    }

    kubernetes_dashboard {
      disabled = true
    }

    network_policy_config {
      disabled = true
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
  # ip_allocation_policy {
  #   cluster_secondary_range_name  = ""
  #   services_secondary_range_name = ""
  # }

  lifecycle {
    # ignore_changes node_pool otherwise it detect no default-pool will recreate cluster
    ignore_changes = ["node_pool"]
  }
}

resource "null_resource" "kubectl" {
  depends_on = ["google_container_cluster.primary", "google_container_node_pool.n2_pool"]

  triggers = {
    # A hack to run everytime
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "gcloud --project=${var.gcp_project} container clusters get-credentials ${local.cluster_name} --region=${var.master_region}"
  }
}

resource "null_resource" "k8s_cluster_admin" {
  depends_on = ["null_resource.kubectl"]

  provisioner "local-exec" {
    command = "kubectl --context=\"${local.kube_context}\" create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)"
  }
}
