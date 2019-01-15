# -------------------------------------------------------------------------------------------------
# IAM Role outputs
# -------------------------------------------------------------------------------------------------

output "roles" {
  description = "The defined roles list"
  value       = "${var.roles}"
}

output "role_ids" {
  description = "The stable and unique string identifying the role."
  value       = ["${aws_iam_role.roles.*.unique_id}"]
}

output "role_arns" {
  description = "The Amazon Resource Name (ARN) specifying the role."
  value       = ["${aws_iam_role.roles.*.arn}"]
}

output "role_names" {
  description = "The name of the role."
  value       = ["${aws_iam_role.roles.*.name}"]
}

output "role_paths" {
  description = "The path to the role."
  value       = ["${aws_iam_role.roles.*.path}"]
}

output "role_session_durations" {
  description = "The maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours."
  value       = ["${aws_iam_role.roles.*.max_session_duration}"]
}

output "role_force_detach_policies" {
  description = "Specifies to force detaching any policies the role has before destroying it."
  value       = ["${aws_iam_role.roles.*.force_detach_policies}"]
}

output "role_policies" {
  description = "A list of the policy definitions."
  value       = ["${aws_iam_policy.policies.*.policy}"]
}

output "role_assume_policies" {
  description = "A list of the policy definitions."
  value       = ["${aws_iam_role.roles.*.assume_role_policy}"]
}

# -------------------------------------------------------------------------------------------------
# IAM Policy outputs
# -------------------------------------------------------------------------------------------------

output "policy_arns" {
  description = "A list of ARN assigned by AWS to the policies."
  value       = ["${aws_iam_policy.policies.*.arn}"]
}

output "policy_ids" {
  description = "A list of unique IDs of the policies."
  value       = ["${aws_iam_policy.policies.*.id}"]
}

output "policy_names" {
  description = "A list of names of the policies."
  value       = ["${aws_iam_policy.policies.*.name}"]
}

output "policy_paths" {
  description = "A list of paths of the policies."
  value       = ["${aws_iam_policy.policies.*.path}"]
}

# -------------------------------------------------------------------------------------------------
# IAM Policy attachments (exclusive)
# -------------------------------------------------------------------------------------------------

output "exclusive_policy_attachment_ids" {
  description = "A list of unique IDs of exclusive policy attachments."
  value       = ["${aws_iam_policy_attachment.exclusive_policy_attachment.*.id}"]
}

output "exclusive_policy_attachment_names" {
  description = "A list of names of exclusive policy attachments."
  value       = ["${aws_iam_policy_attachment.exclusive_policy_attachment.*.name}"]
}

output "exclusive_policy_attachment_policy_arns" {
  description = "A list of ARNs of exclusive policy attachments."
  value       = ["${aws_iam_policy_attachment.exclusive_policy_attachment.*.policy_arn}"]
}

output "exclusive_policy_attachment_role_names" {
  description = "A list of role names of exclusive policy attachments."
  value       = ["${aws_iam_policy_attachment.exclusive_policy_attachment.*.roles}"]
}

# -------------------------------------------------------------------------------------------------
# IAM Policy attachments (imperative)
# -------------------------------------------------------------------------------------------------

output "imperative_policy_attachment_ids" {
  description = "A list of unique IDs of shared policy attachments."
  value       = ["${aws_iam_role_policy_attachment.imperative_policy_attachment.*.id}"]
}

output "imperative_policy_attachment_names" {
  description = "A list of names of shared policy attachments."
  value       = ["${aws_iam_role_policy_attachment.imperative_policy_attachment.*.name}"]
}

output "imperative_policy_attachment_policy_arns" {
  description = "A list of ARNs of shared policy attachments."
  value       = ["${aws_iam_role_policy_attachment.imperative_policy_attachment.*.policy_arn}"]
}

output "imperative_policy_attachment_role_names" {
  description = "A list of role names of shared policy attachments."
  value       = ["${aws_iam_role_policy_attachment.imperative_policy_attachment.*.role}"]
}
