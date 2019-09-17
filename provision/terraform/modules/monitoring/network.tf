data "aws_acm_certificate" "this" {
  domain   = "${var.aws-tls-cert-domain}"
  statuses = ["ISSUED"]
}

resource "aws_security_group" "monitoring" {
  name        = "${var.name}"
  description = "Allow http, https, ssh, docker tls, and port 3000 inbound, all outbound traffic"
  vpc_id      = "${data.aws_vpc.this.id}"

  ingress {
    from_port   = 22
    to_port     = 22
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

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8086
    to_port     = 8086
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_subnet.jenkins-main.cidr_block}"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
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
    Name   = "${var.name}"
    BillTo = "${var.bill-to}"
    Type   = "Demo"
  }
}

resource "aws_elb" "elb" {
  name      = "${var.name}-env-elb"
  instances = ["${aws_instance.app.id}"]

  subnets                   = ["${data.aws_subnet.jenkins-main.id}"]

  security_groups           = ["${aws_security_group.monitoring.id}"]
  cross_zone_load_balancing = true
  idle_timeout              = 60
  connection_draining       = true

  listener {
    lb_port           = "${var.http-port}"
    lb_protocol       = "http"
    instance_port     = 3000
    instance_protocol = "http"
  }

  listener {
    lb_port           = "${var.https-port}"
    lb_protocol        = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.this.arn}"
    instance_port      = 3000
    instance_protocol  = "http"
  }

  listener {
    lb_port           = 22
    lb_protocol       = "tcp"
    instance_port     = 22
    instance_protocol = "tcp"
  }

  listener {
    lb_port           = "${var.docker-tls-port}"
    lb_protocol       = "tcp"
    instance_port     = 2376
    instance_protocol = "tcp"
  }

  listener {
    lb_port           = 8086
    lb_protocol       = "tcp"
    instance_port     = 8086
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

data "aws_route53_zone" "app" {
  count        = "${var.app-use-route53-domain? 1 : 0}"
  name         = "${var.app-route53-zone-name}"
  private_zone = false
}

resource "aws_route53_record" "app" {
  count   = "${var.app-use-route53-domain? 1: 0}"
  zone_id = "${data.aws_route53_zone.app.zone_id}"
  name    = "${var.app-dns-name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.elb.dns_name}"
    zone_id                = "${aws_elb.elb.zone_id}"
    evaluate_target_health = true
  }
}
