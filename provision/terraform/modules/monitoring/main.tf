data "aws_vpc" "this" {
  tags {
    Name = "${var.vpc-name}"
  }
}

data "aws_subnet" "jenkins-main" {
  id = "subnet-e49392cc"
}
