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

variable "aws_cloudwatch_log_retention_days" {
  description = "Number of days to retain CloudWatch logs for"
  default = 7
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

  # Latest versions can be found at https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI_launch_latest.html or by running
  # aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux/recommended --region eu-west-1
  default = {
    eu-west-1    = "ami-2d386654"
    eu-west-2    = "ami-2218f945"
  }
}

variable "aws_ecs_asg_size" {
  description = "Numbers of servers in ASG"
  default = {
    min = "2"
    max = "2"
    desired = "2"
  }
}

variable "aws_efs_docker_volumes_mountpoint" {
  description = "Mount point for location of EFS for Docker volumes"
  default     = "/mnt/efs/docker"
}

variable "mysql_password" {
  description = "Master DB password"
}

variable "rabbitmq_password" {
  description = "Master RabbitMQ password"
}

