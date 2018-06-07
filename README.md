# meta-galaxy-nodes-infra

Recipes on how to provision Pulsar + HTCondor cluster in CESNET's MetaCloud. Recipes are written as generaly as possible but they are still quite specific to CESNET's MetaCloud and its OpenNebula deployment.

## How to run

1. `git clone https://github.com/Misenko/meta-galaxy-nodes-infra.git && cd meta-galaxy-nodes-infra`
2. Create file `secrets.auto.tfvars` and populate it with OpenNebula and message queue credentials.
```
one = {
  endpoint = "https://some.cloud.somewhere.cz:443/RPC2"
  username = "user"
  password = "password"
}

pulsar_message_queue_url = "amqp://user:password@some.queue.somewhere:5672//"
```
3. Edit `variables.tf` to your liking.
4. Unlock your SSH keyring, for example `ssh-add ~/.ssh/id_rsa`.
5. `docker run -it --rm -v $(pwd):/app -v ${SSH_AUTH_SOCK}:/root/ssh -e "SSH_AUTH_SOCK=/root/ssh" misenko/terransibula apply`

Last command will run a Docker container containing Terraform with OpenNebula provider and Ansible provisioner ([https://github.com/Misenko/terransibula](https://github.com/Misenko/terransibula])) so nothing special (except Docker) doesn't have to be installed on the host.

Recipes by default provision one NFS server node, one Pulsar + HTCondor master node and one HTCondor slave node. Number of HTCondor slave nodes can be configured in `variables.tf`.
