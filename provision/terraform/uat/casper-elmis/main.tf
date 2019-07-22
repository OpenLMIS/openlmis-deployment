terraform {
  backend "s3" {
    "bucket" = "openlmis-terraform-states"
    "key"    = "casper-elmis.tf"
    "region" = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "casper-elmis" {
  source = "../../modules/openlmis"

  name                         = "${var.name}"
  bill-to                      = "${var.bill-to}"
  aws-tls-cert-domain          = "${var.aws-tls-cert-domain}"
  app-instance-ssh-user        = "${var.app-instance-ssh-user}"
  app-instance-ssh-key-name    = "${var.app-instance-ssh-key-name}"
  docker-ansible-dir           = "${var.docker-ansible-dir}"
  docker-tls-port              = "${var.docker-tls-port}"
  app-tls-s3-access-key-id     = "${var.aws_access_key_id}"
  app-tls-s3-secret-access-key = "${var.aws_secret_access_key}"
  app-dns-name                 = "${var.app-dns-name}"
  app-use-route53-domain       = "${var.app-use-route53-domain}"
  app-route53-zone-name        = "${var.app-route53-zone-name}"
  app-instance-group           = "${var.app-instance-group}"
  olmis-db-instance-class      = "${var.olmis-db-instance-class}"
  olmis-db-username            = "${var.olmis-db-username}"
  olmis-db-password            = "${var.olmis-db-password}"
  vpc-security-group-id        = "${var.vpc-security-group-id}"
}
