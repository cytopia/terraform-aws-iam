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
