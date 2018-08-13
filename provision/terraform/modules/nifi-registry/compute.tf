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
    Name   = "${var.nr-name}-${var.env}"
    BillTo = "${var.bill-to}"
    Type   = "${var.env}"
  }

  volume_tags {
    Name   = "${var.nr-name}-${var.env}"
    BillTo = "${var.bill-to}"
    Type   = "${var.env}"
  }
}
