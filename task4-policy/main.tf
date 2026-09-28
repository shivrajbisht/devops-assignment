provider "aws" {
    region = "ap-south-1"

    assume_role {
      role_arn = "arn:aws:iam::000000000000:role/TerraformDeployRole"
    }
  }

  # Load the policy JSON from file
  resource "aws_iam_policy" "ci_policy" {
    name        = "ci-least-privilege-policy"
    description = "Least privilege policy for CI pipeline — ECR push, ECS deploy, S3 read only"
    policy      = file("${path.module}/ci_policy.json")

    tags = {
      Environment = "dev"
      Owner       = "shivraj"
    }
  }

  # Attach policy to the ci user (created in task3)
  resource "aws_iam_user_policy_attachment" "ci_policy_attach" {
    user       = "ci"
    policy_arn = aws_iam_policy.ci_policy.arn
  }
