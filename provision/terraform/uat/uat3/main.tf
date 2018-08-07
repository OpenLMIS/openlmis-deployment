terraform {
  backend "s3" {
    "bucket" = "openlmis-terraform-states"
    "key"    = "uat-uat3.tf"
    "region" = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "uat3" {
  source = "../../modules/openlmis"

  name = "${var.name}"
}
