data "template_file" "task_definition_mysql" {
  template = "${file("${path.module}/templates/rdss-datavault-mysql.json")}"

  vars {
    image_url        = "mysql:5.7"
    container_name   = "rdss-datavault-mysql"
    log_group_region = "${var.aws_region}"
    log_group_name   = "${aws_cloudwatch_log_group.datavault.name}"
  }
}

resource "aws_ecs_task_definition" "rdss_datavault_mysql" {
  family                = "rdss-datavault-mysql"
  container_definitions = "${data.template_file.task_definition_mysql.rendered}"
}

resource "aws_ecs_service" "rdss_datavault_mysql" {
  name            = "rdss-datavault-mysql"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.rdss_datavault_mysql.arn}"
  desired_count   = 1
  depends_on      = ["aws_iam_role_policy.ecs_service"]
}
