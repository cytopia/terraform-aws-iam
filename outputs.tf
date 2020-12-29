# -------------------------------------------------------------------------------------------------
# Input variables
# -------------------------------------------------------------------------------------------------

output "var_roles" {
  description = "The defined roles list"
  value       = var.roles
}

output "var_users" {
  description = "The defined users list"
  value       = var.users
}

output "var_permissions_boundaries" {
  description = "The defined roles list"
  value       = var.permissions_boundaries
}

output "var_policies" {
  description = "The transformed policy map"
  value       = var.policies
}

# -------------------------------------------------------------------------------------------------
# Transformed variables
# -------------------------------------------------------------------------------------------------

output "local_policies" {
  description = "The transformed policy map"
  value       = local.policies
}

output "local_role_policies" {
  description = "The transformed role policy map"
  value       = local.role_policies
}

output "local_role_inline_policies" {
  description = "The transformed role inline policy map"
  value       = local.role_inline_policies
}

output "local_role_policy_arns" {
  description = "The transformed role policy arns map"
  value       = local.role_policy_arns
}

output "local_user_policies" {
  description = "The transformed user policy map"
  value       = local.user_policies
}

output "local_user_inline_policies" {
  description = "The transformed user inline policy map"
  value       = local.user_inline_policies
}

output "local_user_policy_arns" {
  description = "The transformed user policy arns map"
  value       = local.user_policy_arns
}

# -------------------------------------------------------------------------------------------------
# Created resources
# -------------------------------------------------------------------------------------------------

output "created_policies" {
  description = "Created customer managed IAM policies"
  value       = aws_iam_policy.policies
}

output "created_roles" {
  description = "Created IAM roles"
  value       = aws_iam_role.roles
}

output "created_role_policy_attachments" {
  description = "Attached role customer managed IAM policies"
  value       = aws_iam_role_policy_attachment.policy_attachments
}

output "created_role_inline_policy_attachments" {
  description = "Attached role inline IAM policies"
  value       = aws_iam_role_policy.inline_policy_attachments
}

output "created_role_policy_arn_attachments" {
  description = "Attached role IAM policy arns"
  value       = aws_iam_role_policy_attachment.policy_arn_attachments
}

output "created_users" {
  description = "Created IAM users"
  value       = aws_iam_user.users
}

output "created_user_policy_attachments" {
  description = "Attached user customer managed IAM policies"
  value       = aws_iam_user_policy_attachment.policy_attachments
}

output "created_user_inline_policy_attachments" {
  description = "Attached user inline IAM policies"
  value       = aws_iam_user_policy.inline_policy_attachments
}

output "created_user_policy_arn_attachments" {
  description = "Attached user IAM policy arns"
  value       = aws_iam_user_policy_attachment.policy_arn_attachments
}
