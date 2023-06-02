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

variable "groups" {
  description = "A list of dictionaries defining all groups."
  type = list(object({
    name        = string                     # Name of the group
    path        = optional(string)           # Defaults to 'var.group_path' if variable is set to null
    policies    = optional(list(string), []) # List of names of policies (must be defined in var.policies)
    policy_arns = optional(list(string), []) # List of existing policy ARN's
    inline_policies = optional(list(object({
      name = string                    # Name of the inline policy
      file = string                    # Path to json or json.tmpl file of policy
      vars = optional(map(string), {}) # Policy template variables {key = val, ...}
    })), [])
  }))
  default = []
}
