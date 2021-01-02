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
