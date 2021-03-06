terraform {
  backend "s3" {
    "bucket" = "openlmis-terraform-states"
    "key"    = "monitoring.tf"
    "region" = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "monitoring" {
  source = "../../modules/monitoring"

  name                         = "${var.name}"
  bill-to                      = "${var.bill-to}"
  vpc-name                     = "${var.vpc-name}"
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
}
