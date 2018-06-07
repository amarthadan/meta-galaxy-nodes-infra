# NFS configuration
data "template_file" "nfs" {
  template = "${file("templates/meta-galaxy-nfs.tpl")}"
  vars {
    CPU = "${var.one["master_cpu"]}"
    VCPU = "${var.one["master_vcpu"]}"
    MEMORY = "${var.one["master_memory"]}"
    IMAGE = "${var.one["image"]}"
    IMAGE_UNAME = "${var.one["image_uname"]}"
    SWAP_IMAGE = "${var.one["swap_image"]}"
    SWAP_IMAGE_UNAME = "${var.one["swap_image_uname"]}"
    NFS_IMAGE_SIZE = "${var.one["nfs_image_size"]}"
    NETWORK_ONE = "${var.one["private_nat_network"]}"
    NETWORK_ONE_UNAME = "${var.one["private_nat_network_uname"]}"
    NETWORK_ONE_SG = ""
    NETWORK_TWO = "${var.one["private_network"]}"
    NETWORK_TWO_UNAME = "${var.one["private_network_uname"]}"
    NETWORK_TWO_SG = "${var.one["security_group"]}"
    CLUSTER_ID = "${var.one["cluster_id"]}"
  }
}

resource "opennebula_template" "nfs" {
  name = "meta-galaxy-nfs"
  description = "${data.template_file.nfs.rendered}"
  permissions = "600"
}

resource "opennebula_vm" "nfs" {
  template_id = "${opennebula_template.nfs.id}"
  permissions = "600"
  connection {
    host = "gw-cloud.ics.muni.cz"
    agent = true
    port = "${var.one["private_nat_network_port_prefix"]}${format("%03v", element(split(".", element(split("|", self.ip), 0)), 3))}"
  }
  provisioner "local-exec" {
    command = "until ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${var.one["private_nat_network_port_prefix"]}${format("%03v", element(split(".", element(split("|", self.ip), 0)), 3))} root@gw-cloud.ics.muni.cz test -e /root/ready; do sleep 5; done"
  }
  provisioner "ansible" {
    become = "yes"
    local = "yes"
    plays {
      playbook = "ansible/nfs.yml"
      extra_vars {
        node_type = "nfs"
        private_network_start_ip = "${var.one["private_network_start_ip"]}"
        private_network_size = "${var.one["private_network_size"]}"
      }
    }
  }
}

# Master configuration
data "template_file" "master" {
  template = "${file("templates/meta-galaxy-node.tpl")}"
  vars {
    CPU = "${var.one["master_cpu"]}"
    VCPU = "${var.one["master_vcpu"]}"
    MEMORY = "${var.one["master_memory"]}"
    IMAGE = "${var.one["image"]}"
    IMAGE_UNAME = "${var.one["image_uname"]}"
    SWAP_IMAGE = "${var.one["swap_image"]}"
    SWAP_IMAGE_UNAME = "${var.one["swap_image_uname"]}"
    NETWORK_ONE = "${var.one["public_network"]}"
    NETWORK_ONE_UNAME = "${var.one["public_network_uname"]}"
    NETWORK_ONE_SG = "${var.one["security_group"]}"
    NETWORK_TWO = "${var.one["private_network"]}"
    NETWORK_TWO_UNAME = "${var.one["private_network_uname"]}"
    NETWORK_TWO_SG = "${var.one["security_group"]}"
    CLUSTER_ID = "${var.one["cluster_id"]}"
  }
}

resource "opennebula_template" "master" {
  name = "meta-galaxy-node-master"
  description = "${data.template_file.master.rendered}"
  permissions = "600"
}

resource "opennebula_vm" "master" {
  template_id = "${opennebula_template.master.id}"
  permissions = "600"
  depends_on = ["opennebula_vm.nfs"]
  connection {
    host = "${self.ip}"
    agent = true
  }
  provisioner "local-exec" {
    command = "until ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${self.ip} test -e /root/ready; do sleep 5; done"
  }
  provisioner "ansible" {
    become = "yes"
    local = "yes"
    plays {
      playbook = "ansible/master.yml"
      extra_vars {
        node_type = "master"
        pulsar_bind_ip = "${self.ip}"
        pulsar_bind_port = "${var.pulsar_bind_port}"
        pulsar_message_queue_url = "${var.pulsar_message_queue_url}"
        condor_master_ip = "${self.ip}"
        nfs_server_ip = "${element(split("|", opennebula_vm.nfs.ip), 1)}"
        private_network_start_ip = "${var.one["private_network_start_ip"]}"
        private_network_size = "${var.one["private_network_size"]}"
      }
    }
  }
}

# Slaves configuration
data "template_file" "slave" {
  template = "${file("templates/meta-galaxy-node.tpl")}"
  vars {
    CPU = "${var.one["slave_cpu"]}"
    VCPU = "${var.one["slave_vcpu"]}"
    MEMORY = "${var.one["slave_memory"]}"
    IMAGE = "${var.one["image"]}"
    IMAGE_UNAME = "${var.one["image_uname"]}"
    SWAP_IMAGE = "${var.one["swap_image"]}"
    SWAP_IMAGE_UNAME = "${var.one["swap_image_uname"]}"
    NETWORK_ONE = "${var.one["private_nat_network"]}"
    NETWORK_ONE_UNAME = "${var.one["private_nat_network_uname"]}"
    NETWORK_ONE_SG = ""
    NETWORK_TWO = "${var.one["private_network"]}"
    NETWORK_TWO_UNAME = "${var.one["private_network_uname"]}"
    NETWORK_TWO_SG = "${var.one["security_group"]}"
    CLUSTER_ID = "${var.one["cluster_id"]}"
  }
}

resource "opennebula_template" "slave" {
  name = "meta-galaxy-node-slave"
  description = "${data.template_file.slave.rendered}"
  permissions = "600"
}

resource "opennebula_vm" "slave" {
  template_id = "${opennebula_template.slave.id}"
  permissions = "600"
  depends_on = ["opennebula_vm.nfs"]
  count = "${var.number_of_slaves}"
  connection {
    host = "gw-cloud.ics.muni.cz"
    agent = true
    port = "${var.one["private_nat_network_port_prefix"]}${format("%03v", element(split(".", self.ip), 3))}"
  }
  provisioner "local-exec" {
    command = "until ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${var.one["private_nat_network_port_prefix"]}${format("%03v", element(split(".", self.ip), 3))} root@gw-cloud.ics.muni.cz test -e /root/ready; do sleep 5; done"
  }
  provisioner "ansible" {
    become = "yes"
    local = "yes"
    plays {
      playbook = "ansible/slave.yml"
      extra_vars {
        node_type = "slave"
        condor_master_ip = "${opennebula_vm.master.ip}"
        nfs_server_ip = "${element(split("|", opennebula_vm.nfs.ip), 1)}"
        private_network_start_ip = "${var.one["private_network_start_ip"]}"
        private_network_size = "${var.one["private_network_size"]}"
      }
    }
  }
}
