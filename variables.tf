# -------------------------------------------------------------------------------------------------
# Policy definition
# -------------------------------------------------------------------------------------------------

# Example policy definition:
#
# policies = [
#   {
#     name = "default-permission-boundary"
#     path = "/boundaries/human/"
#     desc = "Provides default permission boundary for assume roles"
#     file = "boundaries/default.json.tmpl"
#     vars = {
#       currencryDescripe = "*",
#     }
#   },
#   {
#     name = "assume-human-ro-billing"
#     path = "/assume/human/"
#     desc = "Provides read-only access to billing"
#     file = "policies/human/ro-billing.json"
#     vars = {}
#   },
#   {
#     name = "sqs-ro"
#     path = "/custom/human/"
#     desc = "Provides read-only access to SQS"
#     file = "policies/human/sqs-ro.json"
#     vars = {}
#   },
# ]
variable "policies" {
  description = "A list of dictionaries defining all policies."
  type = list(object({
    name = string      # Name of the policy
    path = string      # Defaults to 'var.policy_path' variable is set to null
    desc = string      # Defaults to 'var.policy_desc' variable is set to null
    file = string      # Path to json or json.tmpl file of policy
    vars = map(string) # Policy template variables {key: val, ...}
  }))
  default = []
}


# -------------------------------------------------------------------------------------------------
# Role definition
# -------------------------------------------------------------------------------------------------

# Example role definition:
#
# roles = [
#   {
#     name                 = "ASSUME-ADMIN"
#     path                 = ""
#     desc                 = ""
#     trust_policy_file    = "trust-policies/eng-ops.json"
#     permissions_boundary = null
#     policies             = []
#     inline_policies      = []
#     policy_arns = [
#       "arn:aws:iam::aws:policy/AdministratorAccess",
#     ]
#   },
#   {
#     name                 = "ASSUME-DEV"
#     path                 = ""
#     desc                 = ""
#     trust_policy_file    = "trust-policies/eng-dev.json"
#     permissions_boundary = "arn:aws:iam::aws:policy/my-boundary"
#     policies = [
#       "assume-human-ro-billing",
#     ]
#     inline_policies = []
#     policy_arns = [
#       "arn:aws:iam::aws:policy/PowerUserAccess",
#     ]
#   },
# ]
variable "roles" {
  description = "A list of dictionaries defining all roles."
  type = list(object({
    name                 = string       # Name of the role
    path                 = string       # Defaults to 'var.role_path' variable is set to null
    desc                 = string       # Defaults to 'var.role_desc' variable is set to null
    trust_policy_file    = string       # Path to file of trust/assume policy
    permissions_boundary = string       # ARN to a policy used as permissions boundary (or null/empty)
    policies             = list(string) # List of names of policies (must be defined in var.policies)
    inline_policies = list(object({
      name = string      # Name of the inline policy
      file = string      # Path to json or json.tmpl file of policy
      vars = map(string) # Policy template variables {key = val, ...}
    }))
    policy_arns = list(string) # List of existing policy ARN's
  }))
}


# -------------------------------------------------------------------------------------------------
# User definition
# -------------------------------------------------------------------------------------------------

# Example user definition:
#
# users = [
#   {
#     name       = "ADMIN-USER"
#     path       = ""
#     access_keys = [
#       {
#         name    = "key1"
#         pgp_key = ""
#         status  = ""
#       },
#       {
#         name    = "key2"
#         pgp_key = ""
#         status  = ""
#       }
#     ]
#     permissions_boundary = null
#     policies        = []
#     inline_policies = []
#     policy_arns = [
#       "arn:aws:iam::aws:policy/AdministratorAccess",
#     ]
#   },
#   {
#     name                 = "POWER-USER"
#     path                 = ""
#     access_keys          = []
#     permissions_boundary = "arn:aws:iam::aws:policy/my-boundary"
#     policies = [
#       "assume-human-ro-billing",
#     ]
#     inline_policies = []
#     policy_arns = [
#       "arn:aws:iam::aws:policy/PowerUserAccess",
#     ]
#   },
# ]
variable "users" {
  description = "A list of dictionaries defining all users."
  type = list(object({
    name = string # Name of the user
    path = string # Defaults to 'var.user_path' variable is set to null
    access_keys = list(object({
      name    = string # IaC identifier for first or second IAM access key (not used on AWS)
      pgp_key = string # Leave empty for non or provide a b64-enc pubkey or keybase username
      status  = string # 'Active' or 'Inactive'
    }))
    permissions_boundary = string       # ARN to a policy used as permissions boundary (or null/empty)
    policies             = list(string) # List of names of policies (must be defined in var.policies)
    inline_policies = list(object({
      name = string      # Name of the inline policy
      file = string      # Path to json or json.tmpl file of policy
      vars = map(string) # Policy template variables {key = val, ...}
    }))
    policy_arns = list(string) # List of existing policy ARN's
  }))
}


# -------------------------------------------------------------------------------------------------
# Default Policy settings
# -------------------------------------------------------------------------------------------------

variable "policy_path" {
  description = "The default path under which to create the policy if not specified in the policies list. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division_abc/subdivision_xyz/product_1234/engineering/ to match your company's organizational structure."
  default     = "/"
}

variable "policy_desc" {
  description = "The default description of the policy."
  default     = "Managed by Terraform"
}


# -------------------------------------------------------------------------------------------------
# Default Role settings
# -------------------------------------------------------------------------------------------------

variable "role_path" {
  description = "The path under which to create the role. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division_abc/subdivision_xyz/product_1234/engineering/ to match your company's organizational structure."
  default     = "/"
}

variable "role_desc" {
  description = "The description of the role."
  default     = "Managed by Terraform"
}

variable "role_max_session_duration" {
  description = "The maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours specified in seconds."
  default     = "3600"
}

variable "role_force_detach_policies" {
  description = "Specifies to force detaching any policies the role has before destroying it."
  default     = true
}


# -------------------------------------------------------------------------------------------------
# Default User settings
# -------------------------------------------------------------------------------------------------

variable "user_path" {
  description = "The path under which to create the user. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division_abc/subdivision_xyz/product_1234/engineering/ to match your company's organizational structure."
  default     = "/"
}


# -------------------------------------------------------------------------------------------------
# Default general settings
# -------------------------------------------------------------------------------------------------

variable "tags" {
  description = "Key-value mapping of tags for the IAM role or user."
  type        = map(any)
  default     = {}
}
