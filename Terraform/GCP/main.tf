provider "google" {

  project = "${var.project_id}"
  region = "us-central1"
  zone = "us-central1-c"
}

data "google_compute_zones" "zones" {}

data "google_compute_image" "abc_image" {
  family = "ubuntu-1804-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_network" "vpc_network" {
  name = "vpc-terraform-network"
  auto_create_subnetworks = true
}

resource "google_compute_autoscaler" "autoscale_config" {
  name = "abc-autoscaler"
  project = "${var.project_id}"
  target = google_compute_instance_group_manager.abc_instance_group_manager.self_link

  autoscaling_policy {
    max_replicas = 2
    min_replicas = 1
    cooldown_period = 60
  
    cpu_utilization {
      target = 0.6
    }
  }
}

resource "google_compute_instance_template" "abc_instance_template" {
  name = "abc-instance-template"
  machine_type = "${var.machine_type}"
  can_ip_forward = false
  project = "${var.project_id}"
  metadata_startup_script = file("docker.sh")
  
  disk {
    source_image = data.google_compute_image.abc_image.self_link
  }
  
  network_interface {
    network = google_compute_network.vpc_network.name
  }  
}

resource "google_compute_instance_group_manager" "abc_instance_group_manager" {
  name = "abc-igm"
  project = "${var.project_id}"
  base_instance_name = "terraform"

  version {
    name = "abc"
    instance_template = google_compute_instance_template.abc_instance_template.self_link
  }

  
}

module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = "${var.project_id}"
  network_name = google_compute_network.vpc_network.self_link

  rules = [{
    name                    = "allow-http-ingress"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["80"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  },
  {
    name                    = "deny-ssh-ingress"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = []
    deny = [{
	  protocol = "tcp"
	  ports    = ["22"]
	}]
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }					
  }]
}