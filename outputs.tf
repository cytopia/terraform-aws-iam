# -------------------------------------------------------------------------------------------------
# Input variables
# -------------------------------------------------------------------------------------------------

output "var_roles" {
  description = "The defined roles list"
  value       = var.roles
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

output "local_inline_policies" {
  description = "The transformed inline policy map"
  value       = local.inline_policies
}

output "local_policy_arns" {
  description = "The transformed policy arns map"
  value       = local.policy_arns
}


# -------------------------------------------------------------------------------------------------
# Created resources
# -------------------------------------------------------------------------------------------------

output "created_roles" {
  description = "Created IAM roles"
  value       = aws_iam_role.roles
}

output "created_policies" {
  description = "Created customer managed IAM policies"
  value       = aws_iam_policy.policies
}

output "created_policy_attachments" {
  description = "Attached customer managed IAM policies"
  value       = aws_iam_role_policy_attachment.policy_attachments
}

output "created_inline_policy_attachments" {
  description = "Attached inline IAM policies"
  value       = aws_iam_role_policy.inline_policy_attachments
}

output "created_policy_arn_attachments" {
  description = "Attached IAM policy arns"
  value       = aws_iam_role_policy_attachment.policy_arn_attachments
}
