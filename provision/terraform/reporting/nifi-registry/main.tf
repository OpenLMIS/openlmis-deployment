terraform {
  backend "s3" {
    "bucket" = "openlmis-terraform-states"
    "key"    = "reporting-nifi-registry.tf"
    "region" = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "nifi-registry" {
  source = "../../modules/nifi-registry"

  nr-instance-type = "${var.nr-instance-type}"
  nr-volume-size = "${var.nr-volume-size}"
  nr-ssh-key = "${var.nr-ssh-key}"
  nr-name = "${var.nr-name}"
  env = "${var.env}"
  bill-to = "${var.bill-to}"
  nr-http-port = "${var.nr-http-port}"
  nr-https-port = "${var.nr-https-port}"
  nr-subnet-id = "${var.nr-subnet-id}"
  nr-ami = "${var.nr-ami}"
  nr-vpc-name = "${var.nr-vpc-name}"
  nr-instance-group = "${var.nr-instance-group}"
  nr-instance-ssh-user = "${var.nr-instance-ssh-user}"
  docker-ansible-dir = "${var.docker-ansible-dir}"
  nr-dns-name = "${var.nr-dns-name}"
  nr-tls-s3-access-key-id = "${var.nr-tls-s3-access-key-id}"
  nr-tls-s3-secret-access-key = "${var.nr-tls-s3-secret-access-key}"
  docker-https-port = "${var.docker-https-port}"
}
