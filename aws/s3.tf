resource "aws_s3_bucket" "state" {
  bucket = "rdss-datavault-state"
  acl    = "private"
  tags = "${var.aws_cost_tags}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "archive" {
  bucket = "rdss-datavault-archive"
  acl    = "private"
  tags = "${var.aws_cost_tags}"

  versioning {
    enabled = true
  }
}
