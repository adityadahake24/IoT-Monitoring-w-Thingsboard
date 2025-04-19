terraform {
  backend "s3" {
    bucket         = "aws-thingsboard"
    key            = "statefiles"
    region         = "ap-south-1"
    dynamodb_table = "terraform_locks"
    encrypt        = true
  }
}