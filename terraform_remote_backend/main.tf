resource "aws_instance" "instance-1" {
    ami = "ami-0100e595e1cc1ff7f"
    instance_type = "t2.micro"
}

resource "aws_s3_bucket" "s3" {
    bucket = "terraform-backend-state-file2445"
}

resource "aws_dynamodb_table" "dynamo" {
    billing_mode =  "PAY_PER_REQUEST"
    name = "terraform_remote_backend"
    hash_key = "LockID"

    attribute {
      name = "LockID"
      type = "S"
    }
}
