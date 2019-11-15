# -------------------------------------------------------------------------------------------------
# Set module requirements
# -------------------------------------------------------------------------------------------------

terraform {
  # >= v0.12.6
  required_version = ">= 0.12.6"
}


# -------------------------------------------------------------------------------------------------
# Create defined Policies
# -------------------------------------------------------------------------------------------------

# Create customer managed policies
resource "aws_iam_policy" "policies" {
  for_each = local.policies

  name        = lookup(each.value, "name")
  path        = lookup(each.value, "path", "") == "" ? var.policy_path : lookup(each.value, "path")
  description = lookup(each.value, "desc", "") == "" ? var.policy_desc : lookup(each.value, "desc")
  policy      = templatefile(lookup(each.value, "file"), lookup(each.value, "vars"))
}


# -------------------------------------------------------------------------------------------------
# Create Roles
# -------------------------------------------------------------------------------------------------

# Create roles
resource "aws_iam_role" "roles" {
  for_each = { for role in var.roles : role.name => role }

  name        = lookup(each.value, "name")
  path        = lookup(each.value, "path", "") == "" ? var.role_path : lookup(each.value, "path")
  description = lookup(each.value, "desc", "") == "" ? var.role_desc : lookup(each.value, "desc")

  # This policy defines who/what is allowed to use the current role
  assume_role_policy = file(lookup(each.value, "trust_policy_file"))

  # The boundary defines the maximum allowed permissions which cannot exceed.
  # Even if the policy has higher permission, the boundary sets the final limit
  permissions_boundary = lookup(var.permissions_boundaries, each.key, "")

  # Allow session for X seconds
  max_session_duration  = var.max_session_duration
  force_detach_policies = var.force_detach_policies

  tags = merge(
    map("Name", lookup(each.value, "name")),
    var.tags
  )

}


# -------------------------------------------------------------------------------------------------
# Attach Policies to Role
# -------------------------------------------------------------------------------------------------

# Attach customer managed policies
resource "aws_iam_role_policy_attachment" "policy_attachments" {
  for_each = local.role_policies

  role       = replace(each.key, format(":%s", each.value.name), "")
  policy_arn = aws_iam_policy.policies[each.value.name].arn

  # Terraform has no info that aws_iam_roles and aws_iam_policies
  # must be run first in order to create the roles,
  # so we must explicitly tell it.
  depends_on = [
    aws_iam_role.roles,
    aws_iam_policy.policies,
  ]
}

# Attach policy ARNs
resource "aws_iam_role_policy_attachment" "policy_arn_attachments" {
  for_each = local.policy_arns

  role       = replace(each.key, format(":%s", each.value), "")
  policy_arn = each.value

  # Terraform has no info that aws_iam_roles must be run first in order to create the roles,
  # so we must explicitly tell it.
  depends_on = [aws_iam_role.roles]
}

# Attach inline policies
resource "aws_iam_role_policy" "inline_policy_attachments" {
  for_each = local.inline_policies

  name   = each.value.name
  role   = replace(each.key, format(":%s", each.value.name), "")
  policy = templatefile(lookup(each.value, "file"), lookup(each.value, "vars"))

  # Terraform has no info that aws_iam_roles must be run first in order to create the roles,
  # so we must explicitly tell it.
  depends_on = [aws_iam_role.roles]
}
