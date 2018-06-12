# NFS configuration
data "template_file" "nfs" {
  template = "${file("templates/meta-galaxy-nfs.tpl")}"
  vars {
    CPU = "${var.one["nfs_cpu"]}"
    VCPU = "${var.one["nfs_vcpu"]}"
    MEMORY = "${var.one["nfs_memory"]}"
    IMAGE = "${var.one["image"]}"
    IMAGE_UNAME = "${var.one["image_uname"]}"
    SWAP_IMAGE = "${var.one["swap_image"]}"
    SWAP_IMAGE_UNAME = "${var.one["swap_image_uname"]}"
    NFS_IMAGE_SIZE = "${var.one["nfs_image_size"]}"
    NETWORK = "${var.one["public_network"]}"
    NETWORK_UNAME = "${var.one["public_network_uname"]}"
    NETWORK_SG = "${var.one["security_group"]}"
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
      playbook = "ansible/nfs.yml"
      extra_vars {
        node_type = "nfs"
        public_network_start_ip = "${var.one["public_network_start_ip"]}"
        public_network_size = "${var.one["public_network_size"]}"
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
    NETWORK = "${var.one["public_network"]}"
    NETWORK_UNAME = "${var.one["public_network_uname"]}"
    NETWORK_SG = "${var.one["security_group"]}"
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
        condor_master_ip = "${self.ip}"
        nfs_server_ip = "${opennebula_vm.nfs.ip}"
        public_network_start_ip = "${var.one["public_network_start_ip"]}"
        public_network_size = "${var.one["public_network_size"]}"
        rabbitmq_galaxy_user_name = "${var.rabbitmq_galaxy_user_name}"
        rabbitmq_galaxy_user_password = "${var.rabbitmq_galaxy_user_password}"
        rabbitmq_admin_user_name = "${var.rabbitmq_admin_user_name}"
        rabbitmq_admin_user_password = "${var.rabbitmq_admin_user_password}"
        rabbitmq_galaxy_vhost = "${var.rabbitmq_galaxy_vhost}"
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
    NETWORK = "${var.one["public_network"]}"
    NETWORK_UNAME = "${var.one["public_network_uname"]}"
    NETWORK_SG = "${var.one["security_group"]}"
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
      playbook = "ansible/slave.yml"
      extra_vars {
        node_type = "slave"
        condor_master_ip = "${opennebula_vm.master.ip}"
        nfs_server_ip = "${opennebula_vm.nfs.ip}"
        public_network_start_ip = "${var.one["public_network_start_ip"]}"
        public_network_size = "${var.one["public_network_size"]}"
      }
    }
  }
}
