data "aws_acm_certificate" "this" {
  domain   = "${var.aws-tls-cert-domain}"
  statuses = ["ISSUED"]
}

resource "aws_elb" "elb" {
  name      = "${var.name}-env-elb"
  instances = ["${aws_instance.app.id}"]

  subnets                   = ["subnet-2b27c406", "subnet-357ead7c"]
  security_groups           = ["${var.vpc-security-group-id}", "sg-460a833c"]
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
    ssl_certificate_id = "${data.aws_acm_certificate.this.arn}"
    instance_port      = 80
    instance_protocol  = "http"
  }

  listener {
    lb_port           = 8000
    lb_protocol       = "http"
    instance_port     = 8000
    instance_protocol = "http"
  }

  listener {
    lb_port           = 8080
    lb_protocol       = "http"
    instance_port     = 8080
    instance_protocol = "http"
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
