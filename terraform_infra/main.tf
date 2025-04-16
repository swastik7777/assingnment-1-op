provider "aws" {
  region = "us-east-1"
}


resource "aws_dynamodb_table" "dynamo" {
  name         = "terraform_remote_backend"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock Table"
  }
}

module "vpc" {
  source = "./modules/vpc"
}


module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}


module "ec2" {
  source            = "./modules/ec2"
  public_subnet_ids = module.vpc.public_subnet_ids
  web_sg_id         = module.sg.web_sg_id
  target_group_arn  = module.alb.target_group_arn
}


module "alb" {
  source            = "./modules/alb"
  public_subnet_ids = module.vpc.public_subnet_ids
  vpc_id            = module.vpc.vpc_id
  alb_sg_id         = module.sg.alb_sg_id
}


module "rds" {
  source             = "./modules/rds"
  private_subnet_ids = module.vpc.private_subnet_ids
  db_sg_id           = module.sg.db_sg_id
  db_password        = var.db_password
}
