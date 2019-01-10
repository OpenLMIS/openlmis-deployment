terraform {
  backend "s3" {
    "bucket" = "openlmis-terraform-states"
    "key"    = "functional-test.tf"
    "region" = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "functional-test" {
  source = "../../modules/openlmis"

  name                         = "${var.name}"
  app-instance-ssh-user        = "${var.app-instance-ssh-user}"
  docker-ansible-dir           = "${var.docker-ansible-dir}"
  docker-tls-port              = "${var.docker-tls-port}"
  app-tls-s3-access-key-id     = "${var.aws_access_key_id}"
  app-tls-s3-secret-access-key = "${var.aws_secret_access_key}"
  app-dns-name                 = "${var.app-dns-name}"
  app-instance-group           = "${var.app-instance-group}"
}
