data "aws_vpc" "this" {
  tags {
    Name = "${var.vpc-name}"
  }
}

data "aws_subnet" "this" {
  filter {
    name   = "tag:Name"
    values = ["test-env-subnet1"]
  }
}

data "aws_subnet" "jenkins" {
  filter {
    name   = "tag:Name"
    values = ["Jenkins nodes subnet"]
  }
}
