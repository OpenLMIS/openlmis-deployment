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
}
