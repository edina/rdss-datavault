data "template_file" "ecr_delete_untagged_policy" {
  # This really should delete all untagged images, but you can't set countNumber less than 1
  template = "${file("${path.module}/templates/ecr-delete-untagged-policy.json")}"
}

resource "aws_ecr_repository" "broker" {
  name = "rdss-datavault/broker"
  # Ideally this would be tagged in the same way as other things, but ECR doesn't support tagging
  # tags = "${var.aws_cost_tags}"
}

resource "aws_ecr_lifecycle_policy" "broker" {
  repository = "${aws_ecr_repository.broker.name}"
  policy = "${data.template_file.ecr_delete_untagged_policy.rendered}"
}

resource "aws_ecr_repository" "web" {
  name = "rdss-datavault/web"
  # Ideally this would be tagged in the same way as other things, but ECR doesn't support tagging
  # tags = "${var.aws_cost_tags}"
}

resource "aws_ecr_lifecycle_policy" "web" {
  repository = "${aws_ecr_repository.web.name}"
  policy = "${data.template_file.ecr_delete_untagged_policy.rendered}"
}

resource "aws_ecr_repository" "worker" {
  name = "rdss-datavault/worker"
  # Ideally this would be tagged in the same way as other things, but ECR doesn't support tagging
  # tags = "${var.aws_cost_tags}"
}

resource "aws_ecr_lifecycle_policy" "worker" {
  repository = "${aws_ecr_repository.worker.name}"
  policy = "${data.template_file.ecr_delete_untagged_policy.rendered}"
}
