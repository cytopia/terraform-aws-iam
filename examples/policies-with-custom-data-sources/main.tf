provider "aws" {
  region = "us-east-1"
}

module "aws_iam" {
  source = "../../"

  # Note: we're using the local here as input instead
  roles = local.roles
}

locals {
  # Roles in this list will have the custom policy added to its policy_arns list
  roles_enriched = [
    for role in var.roles : {
      name                 = role.name
      path                 = role.path
      desc                 = role.desc
      trust_policy_file    = role.trust_policy_file
      permissions_boundary = role.permissions_boundary
      policies             = role.policies
      inline_policies      = role.inline_policies
      policy_arns          = concat(role.policy_arns, [aws_iam_policy.s3.arn])
    } if role["name"] == "ROLE-ADMIN"
  ]

  # Roles in this list will be left as they were (condition reversed)
  roles_default = [
    for role in var.roles : {
      name                 = role.name
      path                 = role.path
      desc                 = role.desc
      trust_policy_file    = role.trust_policy_file
      permissions_boundary = role.permissions_boundary
      policies             = role.policies
      inline_policies      = role.inline_policies
      policy_arns          = role.policy_arns
    } if role["name"] != "ROLE-ADMIN"
  ]

  # Let's merge both created lists
  roles = concat(local.roles_enriched, local.roles_default)
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "s3" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
    ]

    resources = [
      "arn:aws:s3::${data.aws_caller_identity.current.account_id}:*"
    ]
  }
}

resource "aws_iam_policy" "s3" {
  name        = "s3-policy"
  path        = "/custom/"
  description = "Custom S3 policy"
  policy      = data.aws_iam_policy_document.s3.json

  lifecycle {
    create_before_destroy = true
  }
}
