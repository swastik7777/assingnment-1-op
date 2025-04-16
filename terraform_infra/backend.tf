terraform {
  backend "s3" {
    bucket         = "bucket-44645"
    key            = "dev/aws-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_remote_backend"
    encrypt        = true
  }
}
