provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.access_key_secret}"
  region     = "${var.region}"
}

data "alicloud_zones" "abc_zones" {}

resource "alicloud_vpc" "ecs-vpc" {
  name       = "ecs-vpc"
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_vswitch" "ecs-vswitch" {
  name              = "ecs-vswitch"
  vpc_id            = "${alicloud_vpc.ecs-vpc.id}"
  cidr_block        = "172.16.0.0/24"
  availability_zone = "${data.alicloud_zones.abc_zones.zones.0.id}"
}

resource "alicloud_vswitch" "ecs-vswitch1" {
  name              = "ecs-vswitch"
  vpc_id            = "${alicloud_vpc.ecs-vpc.id}"
  cidr_block        = "172.16.1.0/24"
  availability_zone = "${data.alicloud_zones.abc_zones.zones.0.id}"
}

resource "alicloud_ess_scaling_group" "default"{
  min_size				= 1
  max_size				= 2
  scaling_group_name	= "scalling-group"
  default_cooldown		= 20
  vswitch_ids			= ["${alicloud_vswitch.ecs-vswitch.id}", "${alicloud_vswitch.ecs-vswitch1.id}"]
  removal_policies		= ["OldestInstance", "NewestInstance"]
}

resource "alicloud_security_group" "ecs-sg" {
  name        = "ecs-sg"
  vpc_id      = "${alicloud_vpc.ecs-vpc.id}"
}

resource "alicloud_ess_scaling_configuration" "default" {
  scaling_group_id  = "${alicloud_ess_scaling_group.default.id}"
  image_id          = "${var.test_image_id}"
  instance_type     = "${var.instance_type}"
  security_group_id = "${alicloud_security_group.ecs-sg.id}"
  force_delete      = true
  active            = true
}

resource "alicloud_ess_scaling_rule" "default" {
  scaling_group_id	= "${alicloud_ess_scaling_group.default.id}"
  metric_name		= "CpuUtilization"
  target_value		= 90
  adjustment_type	= "TotalCapacity"
  adjustment_value	= 1
}

resource "alicloud_security_group_rule" "http-in" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "80/80"
  security_group_id = "${alicloud_security_group.ecs-sg.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_key_pair" "ssh-key" {
  key_name = "ssh-key"
  key_file = "ssh-key.pem"
}

resource "alicloud_instance" "ecs-instance" {
  instance_name			= "ecs-instance"
  image_id 				= "${var.test_image_id}"
  instance_type			= "${var.instance_type}"
  system_disk_category	= "${var.disk_category}"
  security_groups		= ["${alicloud_security_group.ecs-sg.id}"]
  vswitch_id			= "${alicloud_vswitch.ecs-vswitch.id}"
  key_name				= "${alicloud_key_pair.ssh-key.key_name}"
  internet_max_bandwidth_out = 1
  
  provisioner "file" {
    source      = "docker.sh"
    destination = "/tmp/docker.sh"
  }
  
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/docker.sh",
      "sudo sh /tmp/docker.sh",
    ]
  }
}