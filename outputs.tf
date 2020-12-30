# -------------------------------------------------------------------------------------------------
# Policies
# -------------------------------------------------------------------------------------------------

output "policies" {
  description = "Created customer managed IAM policies"
  value       = aws_iam_policy.policies
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
