output "policies" {
  description = "Created customer managed IAM policies"
  value       = module.aws_iam.policies
}

output "users" {
  description = "Created users"
  value       = module.aws_iam.users
}
