provider "aws" {
	alias	= "account_a"
	region	= "ap-south-1"

	assume_role {
		role_arn = "arn:aws:iam::${var.account_a_id}:role/TerraformDeployRole"
	}
	
}

###### User creation ######
resource "aws_iam_user" "engine" {
		provider  = aws.account_a
		name	=  "engine"

	tags = {
		Environment	= "dev"
		Owner		= "Shivraj"
	}
}

resource "aws_iam_user" "ci" {
	provider  = aws.account_a
	name	=	"ci"
	
	tags = {
		Environment	= "dev"
		Owner	= "Shivraj"
	}
}

 resource "aws_iam_user" "group2_users" {
    provider  = aws.account_a
    for_each  = toset(var.group2_users)
    name      = each.value

    tags = {
      Environment = "dev"
      Owner       = "shivraj"
    }
  }

  # Group 1: CLI/programmatic only
  resource "aws_iam_group" "group1" {
    provider = aws.account_a
    name     = "group1"
  }

  # Policy: programmatic access only, no console login
  resource "aws_iam_group_policy" "group1_policy" {
    provider = aws.account_a
    name     = "group1-programmatic-only"
    group    = aws_iam_group.group1.name

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "DenyConsoleAccess"
          Effect = "Deny"
          Action = [
            "iam:CreateLoginProfile",
            "iam:UpdateLoginProfile",
            "iam:GetLoginProfile"
          ]
          Resource = "*"
        }
      ]
    })
  }

  resource "aws_iam_group_membership" "group1_members" {
    provider = aws.account_a
    name     = "group1-membership"
    group    = aws_iam_group.group1.name

    users = [
      aws_iam_user.engine.name,
      aws_iam_user.ci.name
    ]
  }

  # Group 2: Full console + CLI access
  resource "aws_iam_group" "group2" {
    provider = aws.account_a
    name     = "group2"
  }

  resource "aws_iam_group_policy_attachment" "group2_policy" {
    provider   = aws.account_a
    group      = aws_iam_group.group2.name
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  resource "aws_iam_group_membership" "group2_members" {
    provider = aws.account_a
    name     = "group2-membership"
    group    = aws_iam_group.group2.name

    users = [for u in aws_iam_user.group2_users : u.name]
  }

  # Role A: Admin except IAM
  resource "aws_iam_role" "roleA" {
    provider = aws.account_a
    name     = "roleA"

    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${var.account_a_id}:root"
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

  resource "aws_iam_role_policy" "roleA_policy" {
    provider = aws.account_a
    name     = "roleA-admin-except-iam"
    role     = aws_iam_role.roleA.id

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "AllowAllExceptIAM"
          Effect   = "Allow"
          Action   = "*"
          Resource = "*"
        },
        {
          Sid      = "DenyIAM"
          Effect   = "Deny"
          Action   = "iam:*"
          Resource = "*"
        }
      ]
    })
  }

  # Role B: Only permission to assume roleC in Account B
  resource "aws_iam_role" "roleB" {
    provider = aws.account_a
    name     = "roleB"

    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${var.account_a_id}:root"
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

  resource "aws_iam_role_policy" "roleB_policy" {
    provider = aws.account_a
    name     = "roleB-assume-roleC"
    role     = aws_iam_role.roleB.id

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "AllowAssumeRoleC"
          Effect = "Allow"
          Action = "sts:AssumeRole"
          Resource = "arn:aws:iam::${var.account_b_id}:role/roleC"
        }
      ]
    })
  }

	

