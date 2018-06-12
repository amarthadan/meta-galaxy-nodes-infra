CONTEXT = [
  EMAIL = "$$USER[EMAIL]",
  PUBLIC_IP = "$$NIC[IP]",
  ETH0_IP = "$$NIC[IP]",
  SSH_KEY = "$$USER[SSH_KEY]",
  TOKEN = "YES",
  USER_DATA = "#cloud-config
# see https://help.ubuntu.com/community/CloudInit

bootcmd:
- test -L /etc/motd && unlink /etc/motd || /bin/true

runcmd:
- unlink /etc/nologin || /bin/true
- touch /root/ready

mounts:
- [vdb,none,swap,sw,0,0]

write_files:
- path: /etc/nologin
  content: |2

      *** Initial configuration by cloud-init is in progress. Please wait. ***
- path: /etc/motd
  content: |2
                                   cccccccc
                                 ::       :::
                               :c            c:
                               c              c::
                           ::::c:             :  :::
               :::::::::::c:     :                :c:::::::::::
             :::          :                      ::            :::
            c:   __  __      _         ____ _                 _  :c
       :::::c:  |  \/  | ___| |_ __ _ / ___| | ___  _   _  __| |   c
     :::        | |\/| |/ _ \ __/ _` | |   | |/ _ \| | | |/ _` |  :::::::
    c           | |  | |  __/ || (_| | |___| | (_) | |_| | (_| |        ::
    c           |_|  |_|\___|\__\__,_|\____|_|\___/ \__,_|\__,_|         c
     :::                                                          :     c:
        ::::c:               cloud@metacentrum.cz      :        :cc:::::
              :::c                                    :c:::::::::
                 ::::::::::            ::          :::
                          :::::      :::::::::::::::
                              ccccccc:

# sysadmin's master access key
ssh_authorized_keys:
- ssh-dss AAAAB3NzaC1kc3MAAACBAJIwhyfTXj6LeaF5adEINIsRawjlYE8vi1rHK9lb3fC0J+58NSL7mRx5zX0r+HPfnyYptciIG9uh0s7RRRu5c6MHPU5L4Vh7CrAT9SkKg7XmdkfNC6k6a6Dpq2hntwEUjxHvaNbuQA+FtiMEYT3M1/RBR6TdvmEFN2FMcHox5L3zAAAAFQC7Uu5YO5vIVRF80LJ2i7TAqYR3FwAAAIB3ioZ1nxwhYatpdIIaLbK8Za+fFzYT3sObea2jzEItGHVK/smyA4CcMw+54clCx726+0DF9nRnoQUWsh0hYGGdo3s5aPMksX+pqE+w0Nv94osVc+3RkixUjPiNnTLWYcZ/o228Du+FpN1o7AtoGYoQgnL/ZDCwyLWJSApdoAJu0AAAAIAIMihuKkNKHPvgVzJNAAtX+10LH7EAA/iY1wBnotLZ+e1doOCOcqnYw/ULJfBYWx9vMle4cPg8o7yioDn/SfO+GUwQNkr2Z1XkmLwmdWVdCeLgbor2hswyZmS7jF8CvdwMHxKD8ve/RrHkyBUkVxiUUnYT8MmInouPGfdmgR5Wow== cloud-support@metacentrum.cz

power_state:
  mode: reboot
  message: Initial configuration done by cloud-init, forcing reboot to apply changes.

",
  VM_GID = "$$GID",
  VM_GNAME = "$$GNAME",
  VM_ID = "$$VMID",
  VM_UID = "$$UID",
  VM_UNAME = "$$UNAME" ]
CPU = "${CPU}"
DESCRIPTION = "METACLOUD-CentOS-7-x86_64-Winterfell"
DISK = [
  DEV_PREFIX = "vd",
  IMAGE = "${IMAGE}",
  IMAGE_UNAME = "${IMAGE_UNAME}" ]
DISK = [
  DEV_PREFIX = "vd",
  IMAGE = "${SWAP_IMAGE}",
  IMAGE_UNAME = "${SWAP_IMAGE_UNAME}" ]
FEATURES = [
  GUEST_AGENT = "yes" ]
GRAPHICS = [
  LISTEN = "0.0.0.0",
  RANDOM_PASSWD = "YES",
  TYPE = "VNC" ]
LOGO = "images/logos/centos.png"
MEMORY = "${MEMORY}"
NIC = [
  NETWORK = "${NETWORK}",
  NETWORK_UNAME = "${NETWORK_UNAME}",
  SECURITY_GROUPS = "${NETWORK_SG}" ]
OS = [
  ARCH = "x86_64" ]
SCHED_REQUIREMENTS = "(HYPERVISOR=\"kvm\") & (CLUSTER_ID=${CLUSTER_ID})"
VCPU = "${VCPU}"
