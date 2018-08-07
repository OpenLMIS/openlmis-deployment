resource "aws_instance" "app" {
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
    Name = "${var.name}-env"
    BillTo = "OpenLMIS"
    Type = "Demo"
  }
  volume_tags {
    BillTo = "OpenLMIS"
    Type = "Demo"
  }
}
