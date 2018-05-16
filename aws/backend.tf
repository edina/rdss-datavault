terraform {
  backend "s3" {
    bucket = "rdss-datavault-state"
    key    = "terraform-state"
    region = "eu-west-1"
  }
}
