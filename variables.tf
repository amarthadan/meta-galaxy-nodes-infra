variable "one" {
  type = "map"
  default = {
    "image" = "METACLOUD-CentOS-7-x86_64-Winterfell@metacloud-dukan"
    "image_uname" = "oneadmin"
    "swap_image" = "Linux swap"
    "swap_image_uname" = "cerit-sc-admin"
    "nfs_image_size" = "51200"
    "public_network" = "metacloud-brno-public"
    "public_network_uname" = "oneadmin"
    "private_network" = "metacloud-brno-private2-xkimle"
    "private_network_uname" = "xkimle"
    "private_network_start_ip" = "10.4.5.89"
    "private_network_size" = 20
    "private_nat_network" = "metacloud-brno-private2-nat"
    "private_nat_network_uname" = "oneadmin"
    "private_nat_network_port_prefix" = "64"
    "security_group" = "101"
    "cluster_id" = "112"
    "master_cpu" = "2"
    "master_vcpu" = "4"
    "master_memory" = "4096"
    "slave_cpu" = "4"
    "slave_vcpu" = "8"
    "slave_memory" = "8192"
  }
}

variable "number_of_slaves" {
  default = 1
}

variable "pulsar_bind_port" {
  default = 8913
}

variable "pulsar_message_queue_url" {}
