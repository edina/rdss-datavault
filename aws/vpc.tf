data "aws_vpc" "main" {
  id   = "vpc-37d2b752"
}

data "aws_subnet" "a" {
  id   = "subnet-cd0b9d94"
}

data "aws_subnet" "b" {
  id   = "subnet-5f74233a"
}

data "aws_subnet" "c" {
  id   = "subnet-12631c65"
}
