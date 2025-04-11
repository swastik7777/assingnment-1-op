terraform {
    backend "s3" {
        bucket = "terraform-backend-state-file2445"
        region = "us-east-2"
        key = "terraform-remote"
        dynamodb_table = "terraform_remote_backend"
    }
}
