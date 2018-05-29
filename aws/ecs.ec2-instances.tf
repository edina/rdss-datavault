resource "aws_autoscaling_group" "app" {
  name                 = "asg"
  vpc_zone_identifier  = ["${data.aws_subnet.a.id}", "${data.aws_subnet.b.id}", "${data.aws_subnet.c.id}"]
  min_size             = "${var.aws_ecs_asg_size["min"]}"
  max_size             = "${var.aws_ecs_asg_size["max"]}"
  desired_capacity     = "${var.aws_ecs_asg_size["desired"]}"
  launch_configuration = "${aws_launch_configuration.app.name}"
  tags                 = "${var.aws_asg_cost_tags}"
}

data "template_file" "launch_script" {
  template = "${file("${path.module}/templates/ecs-launch-script.sh")}"

  vars {
    cluster        = "${aws_ecs_cluster.main.name}"
    efs_fs_id      = "${aws_efs_file_system.docker_volumes.id}"
    efs_mountpoint = "${var.aws_efs_docker_volumes_mountpoint}"
  }
}

resource "aws_launch_configuration" "app" {
  key_name                    = "${aws_key_pair.auth.id}"
  image_id                    = "${lookup(var.aws_ecs_optimized_amis, var.aws_region)}"
  instance_type               = "${var.aws_ecs_ec2_instance_type}"
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.app.name}"
  security_groups             = ["${aws_security_group.instance_sg.id}"]
  user_data                   = "${data.template_file.launch_script.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance_sg" {
  description = "Controls direct access to application instances"
  vpc_id      = "${data.aws_vpc.main.id}"
  name        = "ecs-inst-sg"
  tags        = "${var.aws_cost_tags}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = "${var.aws_admin_cidr_ingress}"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 0
    to_port         = 65535
    security_groups = ["${aws_security_group.rdss_datavault_broker.id}","${aws_security_group.rdss_datavault_rabbitmq.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
