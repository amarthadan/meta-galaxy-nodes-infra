provider "opennebula" {
  endpoint = "${var.one["endpoint"]}"
  username = "${var.one["username"]}"
  password = "${var.one["password"]}"
}
