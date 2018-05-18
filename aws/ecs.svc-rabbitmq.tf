data "template_file" "task_definition_rabbitmq" {
  template = "${file("${path.module}/templates/rdss-datavault-rabbitmq.json")}"

  vars {
    image_url        = "rabbitmq:3-management-alpine"
    container_name   = "rdss-datavault-rabbitmq"
    log_group_region = "${var.aws_region}"
    log_group_name   = "${aws_cloudwatch_log_group.datavault.name}"
    volume_name      = "rabbitmq"
  }
}

resource "aws_ecs_task_definition" "rdss_datavault_rabbitmq" {
  family                = "rdss-datavault-rabbitmq"
  container_definitions = "${data.template_file.task_definition_rabbitmq.rendered}"

  volume {
    name      = "rabbitmq"
    host_path = "${var.aws_efs_docker_volumes_mountpoint}/rabbitmq"
  }
}

resource "aws_ecs_service" "rdss_datavault_rabbitmq" {
  name            = "rdss-datavault-rabbitmq"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.rdss_datavault_rabbitmq.arn}"
  desired_count   = 1
  depends_on      = ["aws_iam_role_policy.ecs_service"]
}
