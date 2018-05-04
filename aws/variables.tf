variable "aws_region" {
  description = "The AWS region to create things in"
  default     = "eu-west-1"
}

variable "aws_access_key" {
  description = "AWS AccessKey (can also be set through ~/.aws/credentials or AWS_ACCESS_KEY_ID variable)"
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS SecretKey (can also be set through ~/.aws/credentials or AWS_ACCESS_KEY_ID variable)"
  default     = ""
}

variable "aws_profile" {
  description = "Name of an AWS profile to use, as specified in ~/.aws/config"
  default     = ""
}

variable "aws_cost_tags" {
  description = "Cost tags that should be applied to all objects"
  default = {
    Application = "rdss-datavault"
    Group = "rdss-datavault"
  }
}

variable "aws_asg_cost_tags" {
  description = "Cost tags applied to autoscaling group"
  # These should be the same as aws_cost_tags, but they need to be formatted differently
  default = [
    {
      key = "Application"
      value = "rdss-datavault"
      propagate_at_launch = true
    },
    {
      key = "Group"
      value = "rdss-datavault"
      propagate_at_launch = true
    },
  ]
}

variable "aws_key_name" {
  description = "Name of AWS key pair"
  default     = "Datavault"
}

variable "aws_public_key_path" {
  description = "Path to the SSH public key to be used for authentication"
  default     = "id_rsa_datavault.pub"
}

variable "aws_ecs_ec2_instance_type" {
  description = "AWS instance type"
  default     = "t2.small"
}

variable "aws_admin_cidr_ingress" {
  type = "list"
  description = "CIDR list to allow tcp/22 ingress to EC2 instances"
}

variable "aws_ecs_optimized_amis" {
  description = "ECS-optimized AMIs"

  default = {
    us-east-1    = "ami-275ffe31"
    us-east-2    = "ami-62745007"
    us-west-1    = "ami-689bc208"
    us-west-2    = "ami-62d35c02"
    eu-west-1    = "ami-95f8d2f3"
    eu-west-2    = "ami-bf9481db"
    eu-central-1 = "ami-085e8a67"
    ca-central-1 = "ami-ee58e58a"
  }
}

variable "aws_ecs_asg_size" {
  description = "Numbers of servers in ASG"
  default = {
    min = "1"
    max = "1"
    desired = "1"
  }
}
