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
This bucket has to be created manually, it can't be done with Terraform.
In case it needs to be recreated, the bucket is called `rdss-datavault`, and is configured with the following:

* Versioning
* Tags - Group: rdss-datavault
* Tags - Application: rdss-datavault
