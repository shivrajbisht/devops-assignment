provider "aws" {
    region = "ap-south-1"

    assume_role {
      role_arn = "arn:aws:iam::111111111111:role/TerraformDeployRole"
    }
  }

  # Task 5: Fixed terraform snippet
  # Bug 1 fix: Changed principal from :user/roleB -> :role/roleB
  # Bug 2 fix: Replaced s3:* on * with least-privilege actions on target bucket

  data "aws_iam_policy_document" "roleC_trust" {
    statement {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::000000000000:role/roleB"]
      }
    }
  }

  resource "aws_iam_role" "roleC" {
    name               = "roleC"
    assume_role_policy = data.aws_iam_policy_document.roleC_trust.json

    tags = {
      Environment = "dev"
      Owner       = "shivraj"
    }
  }

  resource "aws_iam_role_policy" "roleC_s3" {
    name = "roleC-s3-access"
    role = aws_iam_role.roleC.id

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "AllowSpecificBucketOnly"
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:ListBucket"
          ]
          Resource = [
            "arn:aws:s3:::devops-assignment-app-bucket",
            "arn:aws:s3:::devops-assignment-app-bucket/*"
          ]
        }
      ]
    })
  }
