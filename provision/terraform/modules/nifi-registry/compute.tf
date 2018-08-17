resource "aws_instance" "nifi-registry" {
  ami                    = "${var.nr-ami}"
  instance_type          = "${var.nr-instance-type}"
  key_name               = "${var.nr-ssh-key}"
  subnet_id              = "${var.nr-subnet-id}"
  vpc_security_group_ids = ["${aws_security_group.nifi-registry.id}"]

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = "${var.nr-volume-size}"
    delete_on_termination = "true"
  }

  tags {
    Name        = "${var.nr-name}-${var.env}"
    BillTo      = "${var.bill-to}"
    Type        = "${var.env}"
    DeployGroup = "${var.nr-instance-group}"
  }

  volume_tags {
    Name   = "${var.nr-name}-${var.env}"
    BillTo = "${var.bill-to}"
    Type   = "${var.env}"
  }
}

resource "null_resource" "deploy-docker" {
  depends_on = ["aws_instance.nifi-registry"]

  connection {
    user = "${var.nr-instance-ssh-user}"
    host = "${aws_instance.nifi-registry.public_ip}"
  }

  provisioner "remote-exec" {
    inline = ["ls"]

    connection = {
      type = "ssh"
      user = "${var.nr-instance-ssh-user}"
    }
  }

  provisioner "local-exec" {
    command = "cd ${var.docker-ansible-dir} && mkdir -p vendor/roles && ansible-galaxy install -p vendor/roles -r requirements/galaxy.yml"
  }

  provisioner "local-exec" {
    command = "cd ${var.docker-ansible-dir} && ansible-playbook -vvvv -i inventory docker.yml -e docker_dockerd_tls_port=${var.docker-https-port} -e docker_tls_aws_access_key_id=\"${var.nr-tls-s3-access-key-id}\" -e docker_tls_aws_secret_access_key=\"${var.nr-tls-s3-secret-access-key}\" -e docker_tls_dns_name=${var.nr-dns-name} -e ansible_ssh_user=${var.nr-instance-ssh-user}  --limit ${aws_instance.nifi-registry.public_ip}"
  }
}
