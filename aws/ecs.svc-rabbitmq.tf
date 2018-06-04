data "template_file" "task_definition_rabbitmq" {
  template = "${file("${path.module}/templates/rdss-datavault-rabbitmq.json")}"

  vars {
    image_url        = "rabbitmq:3-management-alpine"
    container_name   = "rdss-datavault-rabbitmq"
    log_group_region = "${var.aws_region}"
    log_group_name   = "${aws_cloudwatch_log_group.datavault.name}"
    rabbitmq_password   = "${var.rabbitmq_password}"
    volume_name      = "rabbitmq"
  }
}

resource "aws_ecs_task_definition" "rdss_datavault_rabbitmq" {
  family                = "rdss-datavault-rabbitmq"
  container_definitions = "${data.template_file.task_definition_rabbitmq.rendered}"
  network_mode          = "bridge"
  task_role_arn         = "${aws_iam_role.ecs_task.arn}"

  volume {
    name      = "rabbitmq"
    host_path = "${var.aws_efs_docker_volumes_mountpoint}/rabbitmq"
  }
}

resource "aws_ecs_service" "rdss_datavault_rabbitmq" {
  name                              = "rdss-datavault-rabbitmq"
  cluster                           = "${aws_ecs_cluster.main.id}"
  task_definition                   = "${aws_ecs_task_definition.rdss_datavault_rabbitmq.arn}"
  desired_count                     = 1
  depends_on                        = ["aws_iam_role_policy.ecs_service"]
  health_check_grace_period_seconds = 300

  load_balancer {
    elb_name       = "${aws_elb.rdss_datavault_rabbitmq.name}"
    container_name = "rdss-datavault-rabbitmq"
    container_port = 15672
  }
}

resource "aws_route53_record" "rdss_datavault_rabbitmq" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "rabbitmq.${aws_route53_zone.internal.name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.rdss_datavault_rabbitmq.dns_name}"
    zone_id                = "${aws_elb.rdss_datavault_rabbitmq.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_elb" "rdss_datavault_rabbitmq" {
  # RabbitMQ uses multiple ports, so we have to use a Classic Load Balancer instead of an Application/Network Load Balancer
  name            = "rdss-datavault-rabbitmq-lb"
  internal        = true
  subnets         = ["${data.aws_subnet.a.id}", "${data.aws_subnet.b.id}", "${data.aws_subnet.c.id}"]
  security_groups = ["${aws_security_group.rdss_datavault_rabbitmq.id}"]
  tags            = "${var.aws_cost_tags}"

  listener {
    instance_port     = "4369"
    instance_protocol = "tcp"
    lb_port           = "4369"
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = "5671"
    instance_protocol = "tcp"
    lb_port           = "5671"
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = "5672"
    instance_protocol = "tcp"
    lb_port           = "5672"
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = "15671"
    instance_protocol = "tcp"
    lb_port           = "15671"
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = "15672"
    instance_protocol = "tcp"
    lb_port           = "15672"
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = "25672"
    instance_protocol = "tcp"
    lb_port           = "25672"
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    target              = "TCP:15672"
    interval            = 5
  }
}

resource "aws_security_group" "rdss_datavault_rabbitmq" {
  description = "Controls access to RabbitMQ"
  vpc_id      = "${data.aws_vpc.main.id}"
  name        = "rdss-datavault-rabbitmq-sg"
  tags        = "${var.aws_cost_tags}"
}

resource "aws_security_group_rule" "rdss_datavault_rabbitmq_ingress_4369" {
  # This cannot be specified as an inline ingress block in aws_security_group.rdss_datavault_rabbitmq
  # as this causes a cyclic dependency error
  security_group_id        = "${aws_security_group.rdss_datavault_rabbitmq.id}"
  type                     = "ingress"
  from_port                = 4369
  to_port                  = 4369
  protocol                 = "tcp"
  cidr_blocks              = ["${data.aws_vpc.main.cidr_block}"]
}

resource "aws_security_group_rule" "rdss_datavault_rabbitmq_ingress_5671" {
  # This cannot be specified as an inline ingress block in aws_security_group.rdss_datavault_rabbitmq
  # as this causes a cyclic dependency error
  security_group_id        = "${aws_security_group.rdss_datavault_rabbitmq.id}"
  type                     = "ingress"
  from_port                = 5671
  to_port                  = 5671
  protocol                 = "tcp"
  cidr_blocks              = ["${data.aws_vpc.main.cidr_block}"]
}

resource "aws_security_group_rule" "rdss_datavault_rabbitmq_ingress_5672" {
  # This cannot be specified as an inline ingress block in aws_security_group.rdss_datavault_rabbitmq
  # as this causes a cyclic dependency error
  security_group_id        = "${aws_security_group.rdss_datavault_rabbitmq.id}"
  type                     = "ingress"
  from_port                = 5672
  to_port                  = 5672
  protocol                 = "tcp"
  cidr_blocks              = ["${data.aws_vpc.main.cidr_block}"]
}

resource "aws_security_group_rule" "rdss_datavault_rabbitmq_ingress_15671" {
  # This cannot be specified as an inline ingress block in aws_security_group.rdss_datavault_rabbitmq
  # as this causes a cyclic dependency error
  security_group_id        = "${aws_security_group.rdss_datavault_rabbitmq.id}"
  type                     = "ingress"
  from_port                = 15671
  to_port                  = 15671
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "rdss_datavault_rabbitmq_ingress_15672" {
  # This cannot be specified as an inline ingress block in aws_security_group.rdss_datavault_rabbitmq
  # as this causes a cyclic dependency error
  security_group_id        = "${aws_security_group.rdss_datavault_rabbitmq.id}"
  type                     = "ingress"
  from_port                = 15672
  to_port                  = 15672
  protocol                 = "tcp"
  cidr_blocks              = ["${data.aws_vpc.main.cidr_block}"]
}

resource "aws_security_group_rule" "rdss_datavault_rabbitmq_ingress_25672" {
  # This cannot be specified as an inline ingress block in aws_security_group.rdss_datavault_rabbitmq
  # as this causes a cyclic dependency error
  security_group_id        = "${aws_security_group.rdss_datavault_rabbitmq.id}"
  type                     = "ingress"
  from_port                = 25672
  to_port                  = 25672
  protocol                 = "tcp"
  cidr_blocks              = ["${data.aws_vpc.main.cidr_block}"]
}

resource "aws_security_group_rule" "rdss_datavault_rabbitmq_egress" {
  # This cannot be specified as an inline egress block in aws_security_group.rdss_datavault_rabbitmq
  # because of aws_security_group_rule.rdss_datavault_rabbitmq_ingress
  security_group_id = "${aws_security_group.rdss_datavault_rabbitmq.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}
