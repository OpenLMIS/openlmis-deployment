data "aws_vpc" "nr" {
  tags {
    Name = "${var.nr-vpc-name}"
  }
}
