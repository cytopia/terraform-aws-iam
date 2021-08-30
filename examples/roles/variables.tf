variable "policies" {
  description = "A list of dictionaries defining all policies."
  type = list(object({
    name = string      # Name of the policy
    path = string      # Defaults to 'var.policy_path' if variable is set to null
    desc = string      # Defaults to 'var.policy_desc' if variable is set to null
    file = string      # Path to json or json.tmpl file of policy
    vars = map(string) # Policy template variables {key: val, ...}
  }))
  default = []
}

variable "roles" {
  description = "A list of dictionaries defining all roles."
  type = list(object({
    name                 = string       # Name of the role
    instance_profile     = string       # Name of the instance profile (attach the role to an instance profile)
    path                 = string       # Defaults to 'var.role_path' if variable is set to null
    desc                 = string       # Defaults to 'var.role_desc' if variable is set to null
    trust_policy_file    = string       # Path to file of trust/assume policy. Will be templated if vars are passed
    trust_policy_vars    = map(string)  # Policy template variables {key = val, ...}
    permissions_boundary = string       # ARN to a policy used as permissions boundary (or null/empty)
    policies             = list(string) # List of names of policies (must be defined in var.policies)
    policy_arns          = list(string) # List of existing policy ARN's
    inline_policies = list(object({
      name = string      # Name of the inline policy
      file = string      # Path to json or json.tmpl file of policy
      vars = map(string) # Policy template variables {key = val, ...}
    }))
  }))
  default = []
}
