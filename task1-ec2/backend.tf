terraform {
  backend "s3" {
    bucket         = "devops-assignment-tfstate-shivraj"
    key            = "task1-ec2/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "devops-assignment-tf-lock"
    encrypt        = true
  }
}
