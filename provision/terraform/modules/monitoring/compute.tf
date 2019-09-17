resource "aws_instance" "app" {
  ami                    = "ami-cd0f5cb6"
  instance_type          = "m5.large"
  key_name               = "${var.app-instance-ssh-key-name}"
  subnet_id              = "${data.aws_subnet.jenkins-main.id}"
  vpc_security_group_ids = ["${aws_security_group.monitoring.id}"]

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = "true"
  }

  tags {
    Name        = "${var.name}-env"
    BillTo      = "${var.bill-to}"
    Type        = "Monitoring"
    DeployGroup = "${var.app-instance-group}"
  }

  volume_tags {
    BillTo = "${var.bill-to}"
    Type   = "Monitoring"
  }
}

resource "null_resource" "deploy-docker" {
  depends_on = ["aws_instance.app"]

  connection {
    user = "${var.app-instance-ssh-user}"
    host = "${aws_instance.app.public_ip}"
  }

  provisioner "remote-exec" {
    inline = ["ls"]

    connection = {
      type = "ssh"
      user = "${var.app-instance-ssh-user}"
    }
  }

  provisioner "local-exec" {
    command = "cd ${var.docker-ansible-dir} && mkdir -p vendor/roles && ansible-galaxy install -p vendor/roles -r requirements/galaxy.yml"
  }

  provisioner "local-exec" {
    command = <<EOF
cd ${var.docker-ansible-dir} && \
  ansible-playbook -vvvv -i inventory docker.yml \
    -e docker_dockerd_tls_port=${var.docker-tls-port} \
    -e docker_tls_aws_access_key_id=\"${var.app-tls-s3-access-key-id}\" \
    -e docker_tls_aws_secret_access_key=\"${var.app-tls-s3-secret-access-key}\" \
    -e docker_tls_dns_name=${var.app-dns-name} \
    -e ansible_ssh_user=${var.app-instance-ssh-user} \
    --limit ${aws_instance.app.public_ip}
EOF
  }
}
