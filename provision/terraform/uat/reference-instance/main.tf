terraform {
  backend "s3" {
    "bucket" = "openlmis-covid-terraform-states"
    "key"    = "reference-instance.tf"
    "region" = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "reference-instance" {
  source = "../../modules/reference-instance"

  name                         = "${var.name}"
  app-instance-ssh-user        = "${var.app-instance-ssh-user}"
  docker-ansible-dir           = "${var.docker-ansible-dir}"
  docker-tls-port              = "${var.docker-tls-port}"
  app-tls-s3-access-key-id     = "${var.aws_access_key_id}"
  app-tls-s3-secret-access-key = "${var.aws_secret_access_key}"
  app-dns-name                 = "${var.app-dns-name}"
  app-instance-group           = "${var.app-instance-group}"
  olmis-db-instance-class      = "${var.olmis-db-instance-class}"
  olmis-db-username            = "${var.olmis-db-username}"
  olmis-db-password            = "${var.olmis-db-password}"
}
