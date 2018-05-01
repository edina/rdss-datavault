resource "aws_ecr_repository" "broker" {
  name = "rdss-datavault/broker"
}

resource "aws_ecr_repository" "web" {
  name = "rdss-datavault/web"
}

resource "aws_ecr_repository" "worker" {
  name = "rdss-datavault/worker"
}
