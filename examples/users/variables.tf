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

variable "users" {
  description = "A list of dictionaries defining all users."
  type = list(object({
    name   = string       # Name of the user
    path   = string       # Defaults to 'var.user_path' if variable is set to null
    groups = list(string) # List of group names to add this user to
    access_keys = list(object({
      name    = string # IaC identifier for first or second IAM access key (not used on AWS)
      pgp_key = string # Leave empty for non or provide a b64-enc pubkey or keybase username
      status  = string # 'Active' or 'Inactive'
    }))
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
