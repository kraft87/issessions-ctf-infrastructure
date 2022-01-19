# Create Kubernetes Cluster
resource "google_container_cluster" "kube_cluster" {
  name                     = "hosted-challenges-cluster"
  initial_node_count       = 1
  remove_default_node_pool = true
  network                  = google_compute_network.vpc_network.id
  subnetwork               = google_compute_subnetwork.kubernetes_subnet.id
  enable_shielded_nodes    = true
  min_master_version       = "1.21.5-gke.1302"
  ip_allocation_policy {}

  release_channel {
    channel = "UNSPECIFIED"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "10.10.100.0/28"

    master_global_access_config {
      enabled = true
    }
  }
  logging_service = "none"

  network_policy {
    enabled = true
  }
}

resource "google_container_node_pool" "standard_pool" {
  name               = "e2-standard-pool"
  cluster            = google_container_cluster.kube_cluster.id
  #initial_node_count = 1
  node_count = 1
  lifecycle {
    ignore_changes = [
      initial_node_count
    ]
  }

  node_config {
    disk_type    = "pd-ssd"
    disk_size_gb = 20
    image_type   = "cos_containerd"
    machine_type = "e2-custom-2-4096"
    #tags         = ["gke-node"]
    metadata = {
      disable-legacy-endpoints = true
    }
  }
  # autoscaling {
  #   min_node_count = 1
  #   max_node_count = 11
  # }
  management {
    auto_repair = true
  }
}

# Allow istio kubernetes api access
resource "google_compute_firewall" "istio_kube_api" {
  name          = "allow-istio-to-kubernetes"
  network       = google_compute_network.vpc_network.name
  direction     = "INGRESS"
  priority      = "1000"
  source_ranges = ["10.10.100.0/28"]
  target_tags   = data.google_compute_instance.kube_node.tags

  allow {
    protocol = "tcp"
    ports    = ["15017"]
  }
}

data "google_compute_instance_group" "kube_node_group" {
  self_link = google_container_node_pool.standard_pool.instance_group_urls.0
}

data "google_compute_instance" "kube_node" {
  self_link = sort(data.google_compute_instance_group.kube_node_group.instances).0
}