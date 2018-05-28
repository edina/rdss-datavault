resource "aws_route53_zone" "internal" {
  name   = "internal.datavault.rdss.com"
  vpc_id = "${data.aws_vpc.main.id}"
  tags   = "${var.aws_cost_tags}"
}
