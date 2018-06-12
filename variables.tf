variable "one" {
  type = "map"
  default = {
    "image" = "METACLOUD-CentOS-7-x86_64-Winterfell@metacloud-dukan"
    "image_uname" = "oneadmin"
    "swap_image" = "Linux swap"
    "swap_image_uname" = "cerit-sc-admin"
    "nfs_image_size" = "102400"
    "public_network" = "metacloud-brno-public-xkimle"
    "public_network_uname" = "xkimle"
    "public_network_start_ip" = "147.251.253.116"
    "public_network_size" = 7
    "security_group" = "101"
    "cluster_id" = "118"
    "nfs_cpu" = "1"
    "nfs_vcpu" = "4"
    "nfs_memory" = "4096"
    "master_cpu" = "2"
    "master_vcpu" = "8"
    "master_memory" = "8192"
    "slave_cpu" = "2"
    "slave_vcpu" = "8"
    "slave_memory" = "8192"
  }
}

variable "number_of_slaves" {
  default = 3
}

variable "pulsar_bind_port" {
  default = 8913
}

variable "rabbitmq_galaxy_user_name" {}
variable "rabbitmq_galaxy_user_password" {}
variable "rabbitmq_admin_user_name" {}
variable "rabbitmq_admin_user_password" {}

variable "rabbitmq_galaxy_vhost" {
  default = "meta-galaxy"
}
