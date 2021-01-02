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

variable "groups" {
  description = "A list of dictionaries defining all groups."
  type = list(object({
    name        = string       # Name of the group
    path        = string       # Defaults to 'var.group_path' if variable is set to null
    policies    = list(string) # List of names of policies (must be defined in var.policies)
    policy_arns = list(string) # List of existing policy ARN's
    inline_policies = list(object({
      name = string      # Name of the inline policy
      file = string      # Path to json or json.tmpl file of policy
      vars = map(string) # Policy template variables {key = val, ...}
    }))
  }))
  default = []
}
