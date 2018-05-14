output "datavault_broker_ecr_repository_url" {
  value = "${aws_ecr_repository.broker.repository_url}"
}

output "datavault_web_ecr_repository_url" {
  value = "${aws_ecr_repository.web.repository_url}"
}

output "datavault_worker_ecr_repository_url" {
  value = "${aws_ecr_repository.worker.repository_url}"
}
