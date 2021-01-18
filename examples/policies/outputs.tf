output "policies" {
  description = "Created customer managed IAM policies"
  value       = module.aws_iam.policies
}
