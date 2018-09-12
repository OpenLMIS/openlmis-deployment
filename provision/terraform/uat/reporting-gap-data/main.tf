terraform {
  backend "s3" {
    "bucket" = "openlmis-terraform-states"
    "key"    = "uat-reporting-gap-data.tf"
    "region" = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "reporting-gap-data" {
  source = "../../modules/openlmis"

  name = "${var.name}"
}
