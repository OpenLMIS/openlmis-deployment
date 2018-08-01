provider "aws" {
  region = "us-east-1"
}

#############
### UAT 3 ###
#############

resource "aws_elb" "uat3" {
  name = "uat3-env-elb"
  instances = ["${aws_instance.uat3-env.id}"]

  subnets = ["subnet-2b27c406", "subnet-357ead7c"]
  security_groups = ["sg-330c8549", "sg-460a833c"]
  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }

  listener {
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "arn:aws:acm:us-east-1:386835390540:certificate/bf52023b-66cc-472c-adc3-b8279b4daf86"
    instance_port = 80
    instance_protocol = "http"
  }

  listener {
    lb_port = 22
    lb_protocol = "tcp"
    instance_port = 22
    instance_protocol = "tcp"
  }

  listener {
    lb_port = 2376
    lb_protocol = "tcp"
    instance_port = 2376
    instance_protocol = "tcp"
  }

  health_check {
    target = "TCP:22"
    healthy_threshold = 10
    unhealthy_threshold = 2
    interval = 30
    timeout = 5
  }

  tags {
    BillTo = "OpenLMIS"
    Type = "Demo"
  }
}

resource "aws_instance" "uat3-env" {
  ami = "ami-cd0f5cb6"
  instance_type = "m5.large"
  key_name = "TestEnvDockerHosts"
  subnet_id = "subnet-2b27c406"
  vpc_security_group_ids = ["sg-330c8549"]
  root_block_device = {
    volume_type = "gp2"
    volume_size = "30"
    delete_on_termination = "true"
  }
  tags {
    Name = "uat3-env"
    BillTo = "OpenLMIS"
    Type = "Demo"
  }
  volume_tags {
    BillTo = "OpenLMIS"
    Type = "Demo"
  }
}

resource "aws_db_instance" "uat3" {
  identifier = "uat3-env-postgres-db"
  allocated_storage = 10
  storage_type = "gp2"
  engine = "postgres"
  engine_version = "9.4.15"
  instance_class = "db.t2.medium"
  name = "open_lmis"
  username = "pHvNEhePnLpdATZe"
  password = "xkRFqrFD6qSq7wjH"
  db_subnet_group_name = "default-vpc-fabce99d"
  vpc_security_group_ids = ["sg-330c8549"]
  apply_immediately = true
  skip_final_snapshot = true

  tags {
    BillTo = "OpenLMIS"
  }
}

#############
### UAT 4 ###
#############

resource "aws_elb" "uat4" {
  name = "uat4-env-elb"
  instances = ["${aws_instance.uat4-env.id}"]

  subnets = ["subnet-2b27c406", "subnet-357ead7c"]
  security_groups = ["sg-330c8549", "sg-460a833c"]
  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }

  listener {
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "arn:aws:acm:us-east-1:386835390540:certificate/bf52023b-66cc-472c-adc3-b8279b4daf86"
    instance_port = 80
    instance_protocol = "http"
  }

  listener {
    lb_port = 22
    lb_protocol = "tcp"
    instance_port = 22
    instance_protocol = "tcp"
  }

  listener {
    lb_port = 2376
    lb_protocol = "tcp"
    instance_port = 2376
    instance_protocol = "tcp"
  }

  health_check {
    target = "TCP:22"
    healthy_threshold = 10
    unhealthy_threshold = 2
    interval = 30
    timeout = 5
  }

  tags {
    BillTo = "OpenLMIS"
    Type = "Demo"
  }
}

resource "aws_instance" "uat4-env" {
  ami = "ami-cd0f5cb6"
  instance_type = "m5.large"
  key_name = "TestEnvDockerHosts"
  subnet_id = "subnet-2b27c406"
  vpc_security_group_ids = ["sg-330c8549"]
  root_block_device = {
    volume_type = "gp2"
    volume_size = "30"
    delete_on_termination = "true"
  }
  tags {
    Name = "uat4-env"
    BillTo = "OpenLMIS"
    Type = "Demo"
  }
  volume_tags {
    BillTo = "OpenLMIS"
    Type = "Demo"
  }
}

resource "aws_db_instance" "uat4" {
  identifier = "uat4-env-postgres-db"
  allocated_storage = 10
  storage_type = "gp2"
  engine = "postgres"
  engine_version = "9.4.15"
  instance_class = "db.t2.medium"
  name = "open_lmis"
  username = "pHvNEhePnLpdATZe"
  password = "xkRFqrFD6qSq7wjH"
  db_subnet_group_name = "default-vpc-fabce99d"
  vpc_security_group_ids = ["sg-330c8549"]
  apply_immediately = true
  skip_final_snapshot = true

  tags {
    BillTo = "OpenLMIS"
  }
}
