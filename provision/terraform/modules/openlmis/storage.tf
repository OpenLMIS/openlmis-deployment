resource "aws_db_instance" "rds" {
  identifier = "${var.name}-env-postgres-db"
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
