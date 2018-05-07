variable "aws_region" {
  description = "The AWS region to create things in"
  default     = "eu-west-1"
}

variable "aws_cost_tags" {
  description = "Cost tags that should be applied to all objects"
  default = {
    Application = "rdss-datavault"
    Group = "rdss-datavault"
  }
}
