# -------------------------------------------------------------------------------------------------
# Set module requirements
# -------------------------------------------------------------------------------------------------

terraform {
  # >= v0.12.6
  required_version = ">= 0.12.6"
}


# -------------------------------------------------------------------------------------------------
# 1. Policies
# -------------------------------------------------------------------------------------------------

# Create customer managed policies
resource "aws_iam_policy" "policies" {
  for_each = local.policies

  name        = lookup(each.value, "name")
  path        = lookup(each.value, "path", null) == null ? var.policy_path : lookup(each.value, "path")
  description = lookup(each.value, "desc", null) == null ? var.policy_desc : lookup(each.value, "desc")
  policy      = templatefile(lookup(each.value, "file"), lookup(each.value, "vars"))
}


# -------------------------------------------------------------------------------------------------
# 2. Roles
# -------------------------------------------------------------------------------------------------

# Create roles
resource "aws_iam_role" "roles" {
  for_each = { for role in var.roles : role.name => role }

  name        = lookup(each.value, "name")
  path        = lookup(each.value, "path", null) == null ? var.role_path : lookup(each.value, "path")
  description = lookup(each.value, "desc", null) == null ? var.role_desc : lookup(each.value, "desc")

  # This policy defines who/what is allowed to use the current role
  assume_role_policy = file(lookup(each.value, "trust_policy_file"))

  # The boundary defines the maximum allowed permissions which cannot exceed.
  # Even if the policy has higher permission, the boundary sets the final limit
  permissions_boundary = lookup(var.permissions_boundaries, each.key, "")

  # Allow session for X seconds
  max_session_duration  = var.role_max_session_duration
  force_detach_policies = var.role_force_detach_policies

  tags = merge(
    map("Name", lookup(each.value, "name")),
    var.tags
  )
}

# Attach customer managed policies to roles
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

# Attach policy ARNs to roles
resource "aws_iam_role_policy_attachment" "policy_arn_attachments" {
  for_each = local.role_policy_arns

  role       = replace(each.key, format(":%s", each.value), "")
  policy_arn = each.value

  # Terraform has no info that aws_iam_roles must be run first in order to create the roles,
  # so we must explicitly tell it.
  depends_on = [aws_iam_role.roles]
}

# Attach inline policies to roles
resource "aws_iam_role_policy" "inline_policy_attachments" {
  for_each = local.role_inline_policies

  name   = each.value.name
  role   = replace(each.key, format(":%s", each.value.name), "")
  policy = templatefile(lookup(each.value, "file"), lookup(each.value, "vars"))

  # Terraform has no info that aws_iam_roles must be run first in order to create the roles,
  # so we must explicitly tell it.
  depends_on = [aws_iam_role.roles]
}


# -------------------------------------------------------------------------------------------------
# 3. Users
# -------------------------------------------------------------------------------------------------

# Create users
resource "aws_iam_user" "users" {
  for_each = { for user in var.users : user.name => user }

  name = lookup(each.value, "name")
  path = lookup(each.value, "path", null) == null ? var.user_path : lookup(each.value, "path")

  # The boundary defines the maximum allowed permissions which cannot exceed.
  # Even if the policy has higher permission, the boundary sets the final limit
  permissions_boundary = lookup(var.permissions_boundaries, each.key, "")

  tags = merge(
    map("Name", lookup(each.value, "name")),
    var.tags
  )
}

# Add 'Active' or 'Inactive' access key to an IAM user
resource "aws_iam_access_key" "access_key" {
  for_each = local.user_access_keys

  user    = split(":", each.key)[0]
  pgp_key = each.value.pgp_key
  status  = each.value.status

  # Terraform has no info that aws_iam_users must be run first in order to create the users,
  # so we must explicitly tell it.
  depends_on = [aws_iam_user.users]
}

# Attach customer managed policies to user
resource "aws_iam_user_policy_attachment" "policy_attachments" {
  for_each = local.user_policies

  user       = replace(each.key, format(":%s", each.value.name), "")
  policy_arn = aws_iam_policy.policies[each.value.name].arn

  # Terraform has no info that aws_iam_users and aws_iam_policies
  # must be run first in order to create the users,
  # so we must explicitly tell it.
  depends_on = [
    aws_iam_user.users,
    aws_iam_policy.policies,
  ]
}

# Attach policy ARNs to user
resource "aws_iam_user_policy_attachment" "policy_arn_attachments" {
  for_each = local.user_policy_arns

  user       = replace(each.key, format(":%s", each.value), "")
  policy_arn = each.value

  # Terraform has no info that aws_iam_users must be run first in order to create the users,
  # so we must explicitly tell it.
  depends_on = [aws_iam_user.users]
}

# Attach inline policies to user
resource "aws_iam_user_policy" "inline_policy_attachments" {
  for_each = local.user_inline_policies

  name   = each.value.name
  user   = replace(each.key, format(":%s", each.value.name), "")
  policy = templatefile(lookup(each.value, "file"), lookup(each.value, "vars"))

  # Terraform has no info that aws_iam_users must be run first in order to create the users,
  # so we must explicitly tell it.
  depends_on = [aws_iam_user.users]
}
