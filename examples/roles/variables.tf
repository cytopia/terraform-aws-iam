variable "policies" {
  description = "A list of dictionaries defining all policies."
  type = list(object({
    name = string                    # Name of the policy
    path = optional(string)          # Defaults to 'var.policy_path' if variable is set to null
    desc = optional(string)          # Defaults to 'var.policy_desc' if variable is set to null
    file = string                    # Path to json or json.tmpl file of policy
    vars = optional(map(string), {}) # Policy template variables {key = val, ...}
  }))
  default = []
}

variable "roles" {
  description = "A list of dictionaries defining all roles."
  type = list(object({
    name                 = string                     # Name of the role
    instance_profile     = optional(string)           # Name of the instance profile
    path                 = optional(string)           # Defaults to 'var.role_path' if variable is set to null
    desc                 = optional(string)           # Defaults to 'var.role_desc' if variable is set to null
    trust_policy_file    = string                     # Path to file of trust/assume policy. Will be templated if vars are passed.
    trust_policy_vars    = optional(map(string), {})  # Policy template variables {key = val, ...}
    permissions_boundary = optional(string)           # ARN to a policy used as permissions boundary (or null/empty)
    policies             = optional(list(string), []) # List of names of policies (must be defined in var.policies)
    policy_arns          = optional(list(string), []) # List of existing policy ARN's
    inline_policies = optional(list(object({
      name = string                    # Name of the inline policy
      file = string                    # Path to json or json.tmpl file of policy
      vars = optional(map(string), {}) # Policy template variables {key = val, ...}
    })), [])
  }))
  default = []
}
