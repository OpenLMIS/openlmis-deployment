######################################################
# This file is currently an unused work in progress!
######################################################

resource "aws_security_group" "casper" {
  name        = "CasperEnvDockerHost"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    # HTTP
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # means "all"
  }

  ingress {
    # HTTPS
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Nifi"
  }

  ingress {
    # Only allow Postgres traffic within the VPC
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    self        = "true"
    description = "PostgreSQL"
  }

  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kafka Connect"
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kafka Topics UI"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2376
    to_port     = 2376
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Grafana"
  }

  ingress {
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0", "::/0"]
  }

  egress {
    # Allow all outgoing traffic
    from_port       = 0
    to_port         = 0
    protocol        = "-1" # means "all"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
