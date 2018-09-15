resource "random_string" "n2_pool_id" {
  length  = 28
  special = false
  upper   = false
  number  = true
}

resource "google_container_node_pool" "n2_pool" {
  # If left blank, Terraform will auto-generate a unique name
  name    = "n2-${random_string.n2_pool_id.result}"
  cluster = "${google_container_cluster.primary.name}"
  region  = "${var.master_region}"
  version = "${local.kubernetes_worker_version}"

  initial_node_count = 1

  autoscaling {
    min_node_count = 0
    max_node_count = 3
  }

  node_config {
    preemptible     = "${var.preemptible}"
    machine_type    = "n1-standard-2"
    service_account = "${google_service_account.gke_node.email}"
    disk_type       = "${var.disk_type}"

    labels {
      env        = "${var.env}"
      managed_by = "terraform"
    }

    workload_metadata_config {
      node_metadata = "SECURE"
    }

    # taint = [{
    #   # TODO: declare preemptible  # key    = "cloud.google.com/gke-preemptible"  # value  = "true"  # effect = "NO_SCHEDULE"
    # }]
  }

  lifecycle {
    # ignore initial_node_count as will auto scale
    ignore_changes        = ["initial_node_count"]
    create_before_destroy = true
  }
}
