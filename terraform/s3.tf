terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "serverless-api/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

