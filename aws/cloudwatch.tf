resource "aws_cloudwatch_log_group" "datavault" {
  name = "datavault"
  tags = "${var.aws_cost_tags}"
  retention_in_days = "${var.aws_cloudwatch_log_retention_days}"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = "ecs-agent"
  tags = "${var.aws_cost_tags}"
  retention_in_days = "${var.aws_cloudwatch_log_retention_days}"
}
