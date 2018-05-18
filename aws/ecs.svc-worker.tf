data "template_file" "task_definition_worker" {
  template = "${file("${path.module}/templates/rdss-datavault-worker.json")}"

  vars {
    image_url           = "${aws_ecr_repository.worker.repository_url}:latest"
    container_name      = "rdss-datavault-worker"
    log_group_region    = "${var.aws_region}"
    log_group_name      = "${aws_cloudwatch_log_group.datavault.name}"
    aws_region          = "${var.aws_region}"
    archive_bucket_name = "${aws_s3_bucket.archive.bucket}"
    mysql_host          = "${aws_db_instance.datavault.address}"
    mysql_password      = "${var.mysql_password}"
  }
}

resource "aws_ecs_task_definition" "rdss_datavault_worker" {
  family                = "rdss-datavault-worker"
  container_definitions = "${data.template_file.task_definition_worker.rendered}"
}

resource "aws_ecs_service" "rdss_datavault_worker" {
  name            = "rdss-datavault-worker"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.rdss_datavault_worker.arn}"
  desired_count   = 1
  depends_on      = ["aws_iam_role_policy.ecs_service"]
}
