provider "aws" {
    alias  = "account_b"
    region = "ap-south-1"

    assume_role {
      role_arn = "arn:aws:iam::${var.account_b_id}:role/TerraformDeployRole"
    }
  }

  # ─────────────────────────────────────────
  # ROLE C — Full access to one S3 bucket
  #           Assumable ONLY by roleB from Account A
  # ─────────────────────────────────────────

  resource "aws_iam_role" "roleC" {
    provider = aws.account_b
    name     = "roleC"

    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "AllowOnlyRoleB"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${var.account_a_id}:role/roleB"
          }
          Action = "sts:AssumeRole"
        }
      ]
    })

    tags = {
      Environment = "dev"
      Owner       = "shivraj"
    }
  }

  # ─────────────────────────────────────────
  # ROLE C POLICY — Scoped to one specific S3 bucket only
  # ─────────────────────────────────────────

  resource "aws_iam_role_policy" "roleC_s3" {
    provider = aws.account_b
    name     = "roleC-s3-access"
    role     = aws_iam_role.roleC.id

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "AllowSpecificBucketAccess"
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:ListBucket"
          ]
          Resource = [
            "arn:aws:s3:::${var.s3_bucket_name}",
            "arn:aws:s3:::${var.s3_bucket_name}/*"
          ]
        }
      ]
    })
  }
