# -------------------------------------------------------------------------------------------------
# Role definition
# -------------------------------------------------------------------------------------------------

# Example role definition:
#
#roles = [
#	{
#		name = "FLA-ENG-DEV"               # required: name of the role
#		path = "/"                         # defaults to 'path' variable if not set
#		desc = "TERRAFORM MANAGED"         # defaults to 'description' variable if not set
#		trust_policy_file = "trust.json"   # required: defines trust/assume policy
#		policy_name = "play-sts-eng-dev"   # required
#		policy_path = "/"                  # defaults to 'policy_path' if not set
#		policy_desc = "description"        # defaults to 'policy_desc' if not set
#		policy_file = "policy.json"        # required: defines the policy
#	}
#]

variable "roles" {
  description = "A list of dictionaries defining all roles."
  type        = "list"
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

variable "max_session_duration" {
  description = "The maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours."
  default     = "3600"
}

variable "force_detach_policies" {
  description = "Specifies to force detaching any policies the role has before destroying it."
  default     = true
}

variable "tags" {
  description = "Key-value mapping of tags for the IAM role."
  type        = "map"
  default     = {}
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

variable "exclusive_policy_attachment" {
  description = "If true, the aws_iam_policy_attachment resource creates exclusive attachments of IAM policies. Across the entire AWS account, all of the users/roles/groups to which a single policy is attached must be declared by a single aws_iam_policy_attachment resource. This means that even any users/roles/groups that have the attached policy via any other mechanism (including other Terraform resources) will have that attached policy revoked by this resource."
  default     = true
}
