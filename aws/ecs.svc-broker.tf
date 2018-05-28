data "template_file" "task_definition_broker" {
  template = "${file("${path.module}/templates/rdss-datavault-broker.json")}"

  vars {
    image_url           = "${aws_ecr_repository.broker.repository_url}:latest"
    container_name      = "rdss-datavault-broker"
    log_group_region    = "${var.aws_region}"
    log_group_name      = "${aws_cloudwatch_log_group.datavault.name}"
    aws_region          = "${var.aws_region}"
    archive_bucket_name = "${aws_s3_bucket.archive.bucket}"
    mysql_host          = "${aws_db_instance.datavault.address}"
    mysql_password      = "${var.mysql_password}"
    # This is the gateway of the Docker daemon, and only works as long as a) broker & rabbitmq are on same host & b) Docker IP range doesn't change
    rabbitmq_host       = "172.17.0.1"
    rabbitmq_password   = "${var.rabbitmq_password}"
    volume_name         = "datavault_working_data"
  }
}

resource "aws_ecs_task_definition" "rdss_datavault_broker" {
  family                = "rdss-datavault-broker"
  container_definitions = "${data.template_file.task_definition_broker.rendered}"
  network_mode          = "bridge"
  task_role_arn         = "${aws_iam_role.ecs_task.arn}"

  # This volume has to be shared with the worker task, in order for the broker to access the metadata after the worker has updated it
  # That's a bug - the worker should instead send the metadata back via rabbitmq - once it's fixed the volume can be removed/unshared
  volume {
    name      = "datavault_working_data"
    host_path = "${var.aws_efs_docker_volumes_mountpoint}/datavault"
  }
}

resource "aws_ecs_service" "rdss_datavault_broker" {
  name                              = "rdss-datavault-broker"
  cluster                           = "${aws_ecs_cluster.main.id}"
  task_definition                   = "${aws_ecs_task_definition.rdss_datavault_broker.arn}"
  desired_count                     = 1
  depends_on                        = ["aws_iam_role_policy.ecs_service"]
  health_check_grace_period_seconds = 300

  load_balancer {
    target_group_arn = "${aws_lb_target_group.rdss_datavault_broker.arn}"
    container_name   = "rdss-datavault-broker"
    container_port   = 8080
  }
}

resource "aws_route53_record" "rdss_datavault_broker" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "broker.${aws_route53_zone.internal.name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.rdss_datavault_broker.dns_name}"
    zone_id                = "${aws_lb.rdss_datavault_broker.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_lb" "rdss_datavault_broker" {
  name                       = "rdss-datavault-broker-lb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.rdss_datavault_broker.id}"]
  subnets                    = ["${data.aws_subnet.a.id}", "${data.aws_subnet.b.id}", "${data.aws_subnet.c.id}"]
  tags                       = "${var.aws_cost_tags}"
}

resource "aws_lb_listener" "rdss_datavault_broker" {
  load_balancer_arn = "${aws_lb.rdss_datavault_broker.arn}"
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.rdss_datavault_broker.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "rdss_datavault_broker" {
  name        = "rdss-datavault-broker-lb-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = "${data.aws_vpc.main.id}"
  target_type = "instance"
}

resource "aws_security_group" "rdss_datavault_broker" {
  description = "Controls access to Broker"
  vpc_id      = "${data.aws_vpc.main.id}"
  name        = "rdss-datavault-broker-sg"
  tags        = "${var.aws_cost_tags}"
}

resource "aws_security_group_rule" "rdss_datavault_broker_ingress" {
  # This cannot be specified as an inline ingress block in aws_security_group.rdss_datavault_broker
  # as this causes a cyclic dependency error
  security_group_id        = "${aws_security_group.rdss_datavault_broker.id}"
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.instance_sg.id}"
}

resource "aws_security_group_rule" "rdss_datavault_broker_egress" {
  # This cannot be specified as an inline egress block in aws_security_group.rdss_datavault_broker
  # because of aws_security_group_rule.rdss_datavault_broker_ingress
  security_group_id = "${aws_security_group.rdss_datavault_broker.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

