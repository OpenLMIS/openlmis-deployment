resource "aws_security_group" "nifi-registry" {
  name        = "${var.nr-name}"
  description = "Allow http https ssh inbound, all outbound traffic"
  vpc_id      = "${data.aws_vpc.nr.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.nr-http-port}"
    to_port     = "${var.nr-http-port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.nr-https-port}"
    to_port     = "${var.nr-https-port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.docker-tls-port}"
    to_port     = "${var.docker-tls-port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name   = "${var.nr-name}"
    BillTo = "${var.bill-to}"
    Type   = "${var.env}"
  }
}

resource "aws_eip" "nifi-registry" {
  instance = "${aws_instance.nifi-registry.id}"
  vpc      = true
}
