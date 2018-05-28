resource "aws_efs_file_system" "docker_volumes" {
  tags           = "${var.aws_cost_tags}"
}

resource "aws_efs_mount_target" "docker_volumes" {
  file_system_id  = "${aws_efs_file_system.docker_volumes.id}"
  subnet_id       = "${data.aws_subnet.a.id}"
  security_groups = [ "${aws_security_group.efs.id}" ]
}

resource "aws_security_group" "efs" {
  description = "Controls access to EFS"
  vpc_id      = "${data.aws_vpc.main.id}"
  name        = "efs-sg"
  tags        = "${var.aws_cost_tags}"

  ingress {
    protocol        = "tcp"
    from_port       = 2049
    to_port         = 2049
    security_groups = [ "${aws_security_group.instance_sg.id}" ]
  }
}
