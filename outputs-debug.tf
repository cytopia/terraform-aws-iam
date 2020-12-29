#
# This file is for development only.
# Comment out the outputs to see how how the transformations work.
#

# -------------------------------------------------------------------------------------------------
# Input variables
# -------------------------------------------------------------------------------------------------

output "debug_var_roles" {
  description = "The defined roles list"
  value       = var.roles
}

output "debug_var_users" {
  description = "The defined users list"
  value       = var.users
}

output "debug_var_permissions_boundaries" {
  description = "The defined roles list"
  value       = var.permissions_boundaries
}

output "debug_var_policies" {
  description = "The transformed policy map"
  value       = var.policies
}


# -------------------------------------------------------------------------------------------------
# Locals (policies)
# -------------------------------------------------------------------------------------------------

output "debug_local_policies" {
  description = "The transformed policy map"
  value       = local.policies
}


# -------------------------------------------------------------------------------------------------
# Locals (roles)
# -------------------------------------------------------------------------------------------------

output "debug_local_role_policies" {
  description = "The transformed role policy map"
  value       = local.role_policies
}

output "debug_local_role_inline_policies" {
  description = "The transformed role inline policy map"
  value       = local.role_inline_policies
}

output "debug_local_role_policy_arns" {
  description = "The transformed role policy arns map"
  value       = local.role_policy_arns
}


# -------------------------------------------------------------------------------------------------
# Locals (users)
# -------------------------------------------------------------------------------------------------

output "debug_local_user_policies" {
  description = "The transformed user policy map"
  value       = local.user_policies
}

output "debug_local_user_access_keys" {
  description = "The transformed user access key map"
  value       = local.user_access_keys
}

output "debug_local_user_inline_policies" {
  description = "The transformed user inline policy map"
  value       = local.user_inline_policies
}

output "debug_local_user_policy_arns" {
  description = "The transformed user policy arns map"
  value       = local.user_policy_arns
}
