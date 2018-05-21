resource "aws_db_instance" "datavault" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "datavault"
  username               = "datavault"
  password               = "${var.mysql_password}"
  parameter_group_name   = "default.mysql5.7"
  tags                   = "${var.aws_cost_tags}"
  vpc_security_group_ids = [ "${aws_security_group.rds.id}" ]
}

resource "aws_security_group" "rds" {
  description = "Controls access to RDS"
  vpc_id      = "${data.aws_vpc.main.id}"
  name        = "rds-sg"
  tags        = "${var.aws_cost_tags}"

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = [ "${aws_security_group.instance_sg.id}" ]
  }
}
