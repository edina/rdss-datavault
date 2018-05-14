data "template_file" "task_definition_broker" {
  template = "${file("${path.module}/templates/rdss-datavault-broker.json")}"

  vars {
    image_url        = "${aws_ecr_repository.broker.repository_url}:latest"
    container_name   = "rdss-datavault-broker"
    log_group_region = "${var.aws_region}"
    log_group_name   = "${aws_cloudwatch_log_group.datavault.name}"
    aws_region       = "${var.aws_region}"
    archive_bucket_name = "${aws_s3_bucket.archive.bucket}"
  }
}

resource "aws_ecs_task_definition" "rdss_datavault_broker" {
  family                = "rdss-datavault-broker"
  container_definitions = "${data.template_file.task_definition_broker.rendered}"
}

resource "aws_ecs_service" "rdss_datavault_broker" {
  name            = "rdss-datavault-broker"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.rdss_datavault_broker.arn}"
  desired_count   = 1
  depends_on      = ["aws_iam_role_policy.ecs_service"]
}
