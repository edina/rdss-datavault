data "template_file" "task_definition_web" {
  template = "${file("${path.module}/templates/rdss-datavault-web.json")}"

  vars {
    image_url        = "${aws_ecr_repository.web.repository_url}:latest"
    container_name   = "rdss-datavault-web"
    log_group_region = "${var.aws_region}"
    log_group_name   = "${aws_cloudwatch_log_group.datavault.name}"
  }
}

resource "aws_ecs_task_definition" "rdss_datavault_web" {
  family                = "rdss-datavault-web"
  container_definitions = "${data.template_file.task_definition_web.rendered}"
  network_mode          = "bridge"
}

resource "aws_ecs_service" "rdss_datavault_web" {
  name            = "rdss-datavault-web"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.rdss_datavault_web.arn}"
  desired_count   = 1
  depends_on      = ["aws_iam_role_policy.ecs_service"]
}
