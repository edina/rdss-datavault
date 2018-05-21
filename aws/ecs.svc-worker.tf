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
    # This is the gateway of the Docker daemon, and only works as long as a) broker & rabbitmq are on same host & b) Docker IP range doesn't change
    rabbitmq_host       = "172.17.0.1"
    rabbitmq_password   = "${var.rabbitmq_password}"
    volume_name         = "datavault_working_data"
  }
}

resource "aws_ecs_task_definition" "rdss_datavault_worker" {
  family                = "rdss-datavault-worker"
  container_definitions = "${data.template_file.task_definition_worker.rendered}"
  network_mode          = "bridge"

  # This volume has to be shared with the broker task, in order for the broker to access the metadata after the worker has updated it
  # That's a bug - the worker should instead send the metadata back via rabbitmq - once it's fixed the volume can be removed/unshared
  volume {
    name      = "datavault_working_data"
    host_path = "${var.aws_efs_docker_volumes_mountpoint}/datavault"
  }
}

resource "aws_ecs_service" "rdss_datavault_worker" {
  name            = "rdss-datavault-worker"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.rdss_datavault_worker.arn}"
  desired_count   = 1
  depends_on      = ["aws_iam_role_policy.ecs_service"]
}
