# -------------------------------------------------------------------------------------------------
# 1. Account Settings
# -------------------------------------------------------------------------------------------------

# Create account alias (if not empty)
resource "aws_iam_account_alias" "default" {
  count = var.account_alias != "" ? 1 : 0

  account_alias = var.account_alias
}

# Setup account password policy
resource "aws_iam_account_password_policy" "default" {
  count = var.account_pass_policy.manage == true ? 1 : 0

  allow_users_to_change_password = var.account_pass_policy.allow_users_to_change_password
  hard_expiry                    = var.account_pass_policy.hard_expiry
  max_password_age               = var.account_pass_policy.max_password_age
  minimum_password_length        = var.account_pass_policy.minimum_password_length
  password_reuse_prevention      = var.account_pass_policy.password_reuse_prevention
  require_lowercase_characters   = var.account_pass_policy.require_lowercase_characters
  require_numbers                = var.account_pass_policy.require_numbers
  require_symbols                = var.account_pass_policy.require_symbols
  require_uppercase_characters   = var.account_pass_policy.require_uppercase_characters
}


# -------------------------------------------------------------------------------------------------
# 2. Identity Providers
# -------------------------------------------------------------------------------------------------

# Create SAML providers
resource "aws_iam_saml_provider" "default" {
  for_each = { for saml in var.providers_saml : saml.name => saml }

  name                   = each.value.name
  saml_metadata_document = file(each.value.file)
  tags                   = var.tags
}

# Create OpenID Connect providers
resource "aws_iam_openid_connect_provider" "default" {
  for_each = { for oidc in var.providers_oidc : md5(oidc.url) => oidc }

  url             = each.value.url
  client_id_list  = each.value.client_id_list
  thumbprint_list = each.value.thumbprint_list
  tags            = var.tags
}


# -------------------------------------------------------------------------------------------------
# 3. Policies
# -------------------------------------------------------------------------------------------------

# Create customer managed policies
resource "aws_iam_policy" "policies" {
  for_each = local.policies

  name        = each.value.name
  path        = each.value.path != null ? each.value.path : var.policy_path
  description = each.value.desc != null ? each.value.desc : var.policy_desc
  policy      = templatefile(each.value.file, each.value.vars)
  tags        = var.tags
}


# -------------------------------------------------------------------------------------------------
# 4. Groups
# -------------------------------------------------------------------------------------------------

# Create groups
resource "aws_iam_group" "groups" {
  for_each = { for group in var.groups : group.name => group }

  name = each.value.name
  path = each.value.path != null ? each.value.path : var.group_path
}

# Attach customer managed policies to group
resource "aws_iam_group_policy_attachment" "policy_attachments" {
  for_each = local.group_policies

  group      = replace(each.key, format(":%s", each.value.name), "")
  policy_arn = aws_iam_policy.policies[each.value.name].arn

  # Terraform has no info that aws_iam_users and aws_iam_policies
  # must be run first in order to create the groups,
  # so we must explicitly tell it.
  depends_on = [
    aws_iam_group.groups,
    aws_iam_policy.policies,
  ]
}

# Attach policy ARNs to group
resource "aws_iam_group_policy_attachment" "policy_arn_attachments" {
  for_each = local.group_policy_arns

  group      = replace(each.key, format(":%s", each.value), "")
  policy_arn = each.value

  # Terraform has no info that aws_iam_users must be run first in order to create the groups,
  # so we must explicitly tell it.
  depends_on = [aws_iam_group.groups]
}

# Attach inline policies to group
resource "aws_iam_group_policy" "inline_policy_attachments" {
  for_each = local.group_inline_policies

  name   = each.value.name
  group  = replace(each.key, format(":%s", each.value.name), "")
  policy = templatefile(each.value.file, each.value.vars)

  # Terraform has no info that aws_iam_users must be run first in order to create the users,
  # so we must explicitly tell it.
  depends_on = [aws_iam_group.groups]
}



# -------------------------------------------------------------------------------------------------
# 5. Users
# -------------------------------------------------------------------------------------------------

# Create users
resource "aws_iam_user" "users" {
  for_each = { for user in var.users : user.name => user }

  name = each.value.name
  path = each.value.path != null ? each.value.path : var.user_path

  # The boundary defines the maximum allowed permissions which cannot exceed.
  # Even if the policy has higher permission, the boundary sets the final limit
  permissions_boundary = each.value.permissions_boundary

  tags = merge(
    {
      Name = each.value.name
    },
    var.tags
  )
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
  policy = templatefile(each.value.file, each.value.vars)

  # Terraform has no info that aws_iam_users must be run first in order to create the users,
  # so we must explicitly tell it.
  depends_on = [aws_iam_user.users]
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

# Add users to groups
resource "aws_iam_user_group_membership" "group_membership" {
  # Note: Only iterate over users which actually have a group specified
  for_each = { for user in var.users : user.name => user if length(user.groups) > 0 }

  user   = each.value.name
  groups = each.value.groups

  # Terraform has no info that aws_iam_user|group must be run first in order to create the
  # attachment, so we must explicitly tell it.
  depends_on = [
    aws_iam_user.users,
    aws_iam_group.groups,
  ]
}


# -------------------------------------------------------------------------------------------------
# 6. Roles
# -------------------------------------------------------------------------------------------------

# Create roles
resource "aws_iam_role" "roles" {
  for_each = { for role in var.roles : role.name => role }

  name        = each.value.name
  path        = each.value.path != null ? each.value.path : var.role_path
  description = each.value.desc != null ? each.value.desc : var.role_desc

  # This policy defines who/what is allowed to use the current role
  assume_role_policy = templatefile(each.value.trust_policy_file, each.value.trust_policy_vars)

  # The boundary defines the maximum allowed permissions which cannot exceed.
  # Even if the policy has higher permission, the boundary sets the final limit
  permissions_boundary = each.value.permissions_boundary

  # Allow session for X seconds
  max_session_duration  = var.role_max_session_duration
  force_detach_policies = var.role_force_detach_policies

  tags = merge(
    {
      Name = each.value.name
    },
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
  policy = templatefile(each.value.file, each.value.vars)

  # Terraform has no info that aws_iam_roles must be run first in order to create the roles,
  # so we must explicitly tell it.
  depends_on = [aws_iam_role.roles]
}

# -------------------------------------------------------------------------------------------------
# 7. Instance profiles
# -------------------------------------------------------------------------------------------------

# Create roles
resource "aws_iam_instance_profile" "profiles" {
  for_each = { for role in var.roles : role.name => role if role.instance_profile != null }

  name = each.value.instance_profile
  path = each.value.path != null ? each.value.path : var.role_path
  role = each.value.name

  tags = merge(
    {
      Name = each.value.name
    },
    var.tags
  )
}
