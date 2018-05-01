output "ecr_datavault_broker_repository_url" {
  value = "${aws_ecr_repository.broker.repository_url}"
}

output "ecr_datavault_web_repository_url" {
  value = "${aws_ecr_repository.web.repository_url}"
}

output "ecr_datavault_worker_repository_url" {
  value = "${aws_ecr_repository.worker.repository_url}"
}

