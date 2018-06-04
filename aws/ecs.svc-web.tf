data "template_file" "task_definition_web" {
  template = "${file("${path.module}/templates/rdss-datavault-web.json")}"

  vars {
    image_url        = "${aws_ecr_repository.web.repository_url}:latest"
    container_name   = "rdss-datavault-web"
    log_group_region = "${var.aws_region}"
    log_group_name   = "${aws_cloudwatch_log_group.datavault.name}"
    broker_host      = "${aws_route53_record.rdss_datavault_broker.fqdn}"
  }
}

resource "aws_ecs_task_definition" "rdss_datavault_web" {
  family                = "rdss-datavault-web"
  container_definitions = "${data.template_file.task_definition_web.rendered}"
  network_mode          = "bridge"
  task_role_arn         = "${aws_iam_role.ecs_task.arn}"
}

resource "aws_ecs_service" "rdss_datavault_web" {
  name                              = "rdss-datavault-web"
  cluster                           = "${aws_ecs_cluster.main.id}"
  task_definition                   = "${aws_ecs_task_definition.rdss_datavault_web.arn}"
  desired_count                     = 1
  depends_on                        = ["aws_iam_role_policy.ecs_service"]
  health_check_grace_period_seconds = 300

  load_balancer {
    target_group_arn = "${aws_lb_target_group.rdss_datavault_web.arn}"
    container_name   = "rdss-datavault-web"
    container_port   = 8080
  }
}

resource "aws_route53_record" "rdss_datavault_web" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "web.${aws_route53_zone.internal.name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.rdss_datavault_web.dns_name}"
    zone_id                = "${aws_lb.rdss_datavault_web.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_lb" "rdss_datavault_web" {
  name                       = "rdss-datavault-web-lb"
  # Set this to external for now, since we don't actually have an external DNS zone to access it through
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.rdss_datavault_web.id}"]
  subnets                    = ["${data.aws_subnet.a.id}", "${data.aws_subnet.b.id}", "${data.aws_subnet.c.id}"]
  tags                       = "${var.aws_cost_tags}"
}

resource "aws_lb_listener" "rdss_datavault_web" {
  load_balancer_arn = "${aws_lb.rdss_datavault_web.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.rdss_datavault_web.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "rdss_datavault_web" {
  name        = "rdss-datavault-web-lb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${data.aws_vpc.main.id}"
  target_type = "instance"
}

resource "aws_security_group" "rdss_datavault_web" {
  description = "Controls access to web app"
  vpc_id      = "${data.aws_vpc.main.id}"
  name        = "rdss-datavault-web-sg"
  tags        = "${var.aws_cost_tags}"
}

resource "aws_security_group_rule" "rdss_datavault_web_ingress" {
  # This cannot be specified as an inline ingress block in aws_security_group.rdss_datavault_web
  # as this causes a cyclic dependency error
  security_group_id        = "${aws_security_group.rdss_datavault_web.id}"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "rdss_datavault_web_egress" {
  # This cannot be specified as an inline egress block in aws_security_group.rdss_datavault_web
  # because of aws_security_group_rule.rdss_datavault_web_ingress
  security_group_id = "${aws_security_group.rdss_datavault_web.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

