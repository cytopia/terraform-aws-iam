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
