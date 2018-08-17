terraform {
  backend "s3" {
    "bucket" = "openlmis-terraform-states"
    "key"    = "uat-uat4.tf"
    "region" = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "uat4" {
  source = "../../modules/openlmis"

  name                         = "${var.name}"
  app-instance-ssh-user        = "${var.app-instance-ssh-user}"
  docker-ansible-dir           = "${var.docker-ansible-dir}"
  docker-https-port            = "${var.docker-https-port}"
  app-tls-s3-access-key-id     = "${var.app-tls-s3-access-key-id}"
  app-tls-s3-secret-access-key = "${var.app-tls-s3-secret-access-key}"
  app-dns-name                 = "${var.app-dns-name}"
}
