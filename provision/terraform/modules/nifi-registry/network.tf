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
    from_port   = "${var.http-port}"
    to_port     = "${var.http-port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.https-port}"
    to_port     = "${var.https-port}"
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
  count    = "${var.nr-assign-elastic-ip ? 1 : 0}"
  instance = "${aws_instance.nifi-registry.id}"
  vpc      = true
}

resource "aws_elb" "nr-elb" {
  name      = "${var.nr-name}-${var.env}-elb"
  instances = ["${aws_instance.nifi-registry.id}"]

  subnets                   = "${var.nr-elb-subnets}"
  security_groups           = ["${aws_security_group.nifi-registry.id}"]
  cross_zone_load_balancing = true
  idle_timeout              = 60
  connection_draining       = true

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  listener {
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${var.nr-acm-certificate-arn}"
    instance_port      = 80
    instance_protocol  = "http"
  }

  listener {
    lb_port           = 22
    lb_protocol       = "tcp"
    instance_port     = 22
    instance_protocol = "tcp"
  }

  listener {
    lb_port           = 2376
    lb_protocol       = "tcp"
    instance_port     = 2376
    instance_protocol = "tcp"
  }

  health_check {
    target              = "TCP:22"
    healthy_threshold   = 10
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }

  tags {
    BillTo = "${var.bill-to}"
    Type   = "Demo"
  }
}

data "aws_route53_zone" "selected" {
  count        = "${var.nr-use-route53-domain? 1 : 0}"
  name         = "${var.nr-route53-zone-name}"
  private_zone = false
}

resource "aws_route53_record" "nifi" {
  count   = "${var.nr-use-route53-domain? 1: 0}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.nr-nifi-domain}"
  type    = "A"

  alias {
    name                   = "${aws_elb.nr-elb.dns_name}"
    zone_id                = "${aws_elb.nr-elb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "superset" {
  count   = "${var.nr-use-route53-domain? 1: 0}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.nr-superset-domain}"
  type    = "A"

  alias {
    name                   = "${aws_elb.nr-elb.dns_name}"
    zone_id                = "${aws_elb.nr-elb.zone_id}"
    evaluate_target_health = true
  }
}
