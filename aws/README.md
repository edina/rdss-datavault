# Deployment with Terraform + Amazon ECS

- [Requirements](#requirements)
- [Check out the code](#check-out-the-code)
- [Bootstrap](#bootstrap)

## Requirements

You need [Terraform](https://www.terraform.io) and [AWS CLI](https://aws.amazon.com/cli/) installed locally.

## Bootstrap

Start setting up AWS CLI with your credentials an the preferrred region. Run the following command to introduce the preferred region, secret key, etc.:

    $ aws configure

Initialise terraform:

    $ terraform init

## Usage

Generate an execution plan for Terraform:

    $ terraform plan

Apply the changes:

    $ terraform apply

## State

The terraform state is stored within an S3 bucket, configured in `backend.tf`.
This bucket is defined in `s3.tf`, but there's a chicken-and-egg problem here - Terraform needs the bucket to exist before it can do anything, including creating the bucket.
If the bucket is ever deleted, or you want to move to a different bucket, you'll need to create the bucket some other way, e.g. through the web interface.
The bucket is marked with `prevent_destroy = true`, so that it shouldn't be deleted, but you should always take care with it.
