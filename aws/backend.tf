terraform {
  backend "s3" {
    bucket = "rdss-datavault"
    key    = "terraform-state"
    region = "eu-west-1"
  }
}
