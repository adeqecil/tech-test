# Variables used in main.tf
variable "access_key" {
    description = "Alibaba Cloud access key"
}

variable "access_key_secret" {
    description = "Alibaba Cloud access key secret"
}

variable "test_image_id" {
    description = "Ubuntu 18.04 2021-06-23"
    default = "ubuntu_18_04_x64_20G_alibase_20210623.vhd"
}

variable "instance_type" {
	description = "1vcpu 1GiB avaliable for Malaysia"
	default = "ecs.xn4.small"
}

variable "region" {
    description = "Alibaba Cloud Region set to Malaysia"
    default = "ap-southeast-3"
}

variable "disk_category" {
	description = "Standard SSD"
	default = "cloud_ssd"
}