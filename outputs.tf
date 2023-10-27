# -------------------------------------------------------------------------------------------------
# Account Settings
# -------------------------------------------------------------------------------------------------

output "account_alias" {
  description = "Created Account alias."
  value       = aws_iam_account_alias.default
}

output "account_pass_policy" {
  description = "Created Account password policy."
  value       = aws_iam_account_password_policy.default
}


# -------------------------------------------------------------------------------------------------
# Identity Providers
# -------------------------------------------------------------------------------------------------

output "providers_saml" {
  description = "Created SAML providers."
  value       = aws_iam_saml_provider.default
}

output "providers_oidc" {
  description = "Created OpenID Connect providers."
  value       = aws_iam_openid_connect_provider.default
}


# -------------------------------------------------------------------------------------------------
# Policies
# -------------------------------------------------------------------------------------------------

output "policies" {
  description = "Created customer managed IAM policies"
  value       = aws_iam_policy.policies
}


# -------------------------------------------------------------------------------------------------
# Groups
# -------------------------------------------------------------------------------------------------

output "groups" {
  description = "Created IAM groups"
  value       = aws_iam_group.groups
}

output "group_policy_attachments" {
  description = "Attached group customer managed IAM policies"
  value       = aws_iam_group_policy_attachment.policy_attachments
}

output "group_inline_policy_attachments" {
  description = "Attached group inline IAM policies"
  value       = aws_iam_group_policy.inline_policy_attachments
}

output "group_policy_arn_attachments" {
  description = "Attached group IAM policy arns"
  value       = aws_iam_group_policy_attachment.policy_arn_attachments
}


# -------------------------------------------------------------------------------------------------
# Users
# -------------------------------------------------------------------------------------------------

output "users" {
  description = "Created IAM users"
  value       = aws_iam_user.users
}

output "user_policy_attachments" {
  description = "Attached user customer managed IAM policies"
  value       = aws_iam_user_policy_attachment.policy_attachments
}

output "user_inline_policy_attachments" {
  description = "Attached user inline IAM policies"
  value       = aws_iam_user_policy.inline_policy_attachments
}

output "user_policy_arn_attachments" {
  description = "Attached user IAM policy arns"
  value       = aws_iam_user_policy_attachment.policy_arn_attachments
}

output "user_group_memberships" {
  description = "Assigned user/group memberships"
  value       = aws_iam_user_group_membership.group_membership
}

output "user_access_keys" {
  description = "Created access keys"
  sensitive   = true
  value       = aws_iam_access_key.access_key
}


# -------------------------------------------------------------------------------------------------
# Roles
# -------------------------------------------------------------------------------------------------

output "roles" {
  description = "Created IAM roles"
  value       = aws_iam_role.roles
}

output "role_policy_attachments" {
  description = "Attached role customer managed IAM policies"
  value       = aws_iam_role_policy_attachment.policy_attachments
}

output "role_inline_policy_attachments" {
  description = "Attached role inline IAM policies"
  value       = aws_iam_role_policy.inline_policy_attachments
}

output "role_policy_arn_attachments" {
  description = "Attached role IAM policy arns"
  value       = aws_iam_role_policy_attachment.policy_arn_attachments
}
