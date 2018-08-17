resource "aws_elb" "elb" {
  name      = "${var.name}-env-elb"
  instances = ["${aws_instance.app.id}"]

  subnets                   = ["subnet-2b27c406", "subnet-357ead7c"]
  security_groups           = ["sg-330c8549", "sg-460a833c"]
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
    ssl_certificate_id = "arn:aws:acm:us-east-1:386835390540:certificate/bf52023b-66cc-472c-adc3-b8279b4daf86"
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
    BillTo = "OpenLMIS"
    Type   = "Demo"
  }
}
