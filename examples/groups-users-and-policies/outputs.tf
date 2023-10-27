output "policies" {
  description = "Created customer managed IAM policies"
  value       = module.aws_iam.policies
}

output "groups" {
  description = "Created groups"
  value       = module.aws_iam.groups
}

output "users" {
  description = "Created users"
  value       = module.aws_iam.users
}

output "users_keys" {
  description = "Created user's access keys"
  sensitive   = true
  value       = module.aws_iam.user_access_keys
}
