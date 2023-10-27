# Terraform module: AWS IAM

**[Features](#star-features)** |
**[Important](#exclamation-important)** |
**[Examples](#bulb-examples)** |
**[Usage](#computer-usage)** |
**[Requirements](#requirements)** |
**[Inputs](#required-inputs)** |
**[Outputs](#outputs)** |
**[Related projects](#related-projects)** |
**[Authors](#authors)** |
**[License](#license)**

[![lint](https://github.com/Flaconi/terraform-aws-iam-roles/workflows/lint/badge.svg)](https://github.com/Flaconi/terraform-aws-iam-roles/actions?query=workflow%3Alint)
[![test](https://github.com/Flaconi/terraform-aws-iam-roles/workflows/test/badge.svg)](https://github.com/Flaconi/terraform-aws-iam-roles/actions?query=workflow%3Atest)
[![Tag](https://img.shields.io/github/tag/Flaconi/terraform-aws-iam-roles.svg)](https://github.com/Flaconi/terraform-aws-iam-roles/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)


This Terraform module manages AWS IAM to its full extend.

It is only required to have a single module invocation per AWS account, as this module allows the creation of unlimited resources and you will therefore have an auditable single source of truth for IAM.


## :star: Features

* Completely configurable via `terraform.tfvars` only
* Arbitrary number of IAM **policies**, **groups**, **users** and **roles**
* Policies can be defined via **JSON** or **templatable JSON** files
* Policies can be defined via [`aws_iam_policy_document`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) ([Example here](examples/policies-with-custom-data-sources))
* Groups, users and roles can be attached to an arbitrary number of **custom policies**, **inline policies** and existing **policy ARN's**
* Users can be added to an arbitrary number of **groups**
* Users support AWS access/secret **[key rotation](examples/access-key-rotation/)**
* Roles support **trusted entities**
* Arbitrary number of **identity providers** (SAML and OIDC)
* **Account settings**: account alias and password policy


## :exclamation: Important

When creating an IAM user with an `Inactive` access key, it is initially created with access key set to `Active`. You will have to run it a second time in order to deactivate the access key.
This is either an issue with the terraform resource [`aws_iam_access_key`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) or with the AWS api itself.


## :bulb: Examples

This module is very flexible and might look a bit complicated at first glance. To show off a few features which are possible, have a look at the following examples.

**:page_facing_up: Also see each example README.md file for more detailed explanations on each of the covered resources. They serve as a documentation purpose as well.**

| Example                                                           | Description                                              |
|-------------------------------------------------------------------|----------------------------------------------------------|
| **POLICIES**                                                      |                                                          |
| [JSON policies](examples/policies/)                               | Define JSON policies with variable templating            |
| [Policies with custom data sources](examples/policies-with-custom-data-sources) | Use terraform's [`aws_iam_policy_document`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) data source to create policies and attach them to defined roles.  |
| **GROUPS / USERS**                                                |                                                          |
| [Groups](examples/groups/)                                        | Defines groups                                           |
| [Users](examples/users/)                                          | Defines users                                            |
| [Groups, users and policies](examples/groups-users-and-policies/) | Defines groups, users and policies                       |
| [Access key rotation](examples/access-key-rotation/)              | Shows how to safely rotate AWS access keys for IAM users |
| **ROLES**                                                         |                                                          |
| [Roles](examples/roles/)                                          | Define roles (cross-account assumable)                   |
| **ADVANCED**                                                      |                                                          |
| [SAML Login](examples/saml-login/)                                | Login into AWS via SAML identity provider and assume cross-account roles. Also read about best-practices for separating login roles and permission roles. |


## :computer: Usage

1. [Use `terraform.tfvars` only](#use-terraformtfvars-only)
2. [Use Module](#use-module)
3. [Use Terragrunt](#use-terragrunt)

### Use `terraform.tfvars` only

You can simply clone this repository and add your `terraform.tfvars` file into the root of this directory.

`terraform.tfvars`
```hcl
# --------------------------------------------------------------------------------
# Account Management
# --------------------------------------------------------------------------------

account_alias = "prod-account"

account_pass_policy = {
  manage                         = true
  allow_users_to_change_password = true
  hard_expiry                    = false
  max_password_age               = 365
  minimum_password_length        = 8
  password_reuse_prevention      = 5
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  require_uppercase_characters   = true
}

# --------------------------------------------------------------------------------
# Account Identity provider
# --------------------------------------------------------------------------------

# Add a SAML provider for login
providers_saml = [
  {
    name = "AzureAD"
    file = "path/to/azure/meta.xml"
  },
  {
    name = "ADFS"
    file = "path/to/adfs/meta.xml"
  }
]

# --------------------------------------------------------------------------------
# Policies, Groups, Users and Roles
# --------------------------------------------------------------------------------

# List of policies to create
# Policies defined here can be used by name in groups, users and roles list
policies = [
  {
    name = "ro-billing"
    path = "/assume/human/"
    desc = "Provides read-only access to billing"
    file = "policies/ro-billing.json"
    vars = {}
  },
]

# List of groups to manage
# Groups defined here can be used in users list
groups = [
  {
    name                 = "admin-group"
    path                 = null
    policies             = []
    policy_arns = [
      "arn:aws:iam::aws:policy/AdministratorAccess",
    ]
    inline_policies      = []
  },
]

# List of users to manage
users = [
  {
    name                 = "admin"
    path                 = null
    groups               = ["admin-group"]
    access_keys          = []
    permissions_boundary = null
    policies             = []
    policy_arns          = []
    inline_policies      = []
  },
]

# List of roles to manage
roles = [
  {
    name                 = "ROLE-ADMIN"
    instance_profile     = null
    path                 = ""
    desc                 = ""
    trust_policy_file    = "trust-policies/admin.json"
    permissions_boundary = null
    policies             = []
    policy_arns = [
      "arn:aws:iam::aws:policy/AdministratorAccess",
    ]
    inline_policies      = []
  },
  {
    name                 = "ROLE-DEV"
    instance_profile     = null
    path                 = ""
    desc                 = ""
    trust_policy_file    = "trust-policies/dev.json"
    permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"
    policies = [
      "ro-billing",
    ]
    policy_arns = [
      "arn:aws:iam::aws:policy/PowerUserAccess",
    ]
    inline_policies      = []
  },
]

# --------------------------------------------------------------------------------
# Defaults
# --------------------------------------------------------------------------------

policy_path = "/"
policy_desc = "Managed by Terraform"
group_path  = "/"
user_path   = "/"
role_path   = "/"
role_desc   = "Managed by Terraform"

role_max_session_duration  = 3600
role_force_detach_policies = true

tags = {
  env   = "prod"
  owner = "terraform"
}
```


### Use Module

Create your own module by sourcing this module.

```hcl
module "iam_roles" {
  source = "github.com/Flaconi/terraform-aws-iam-roles?ref=v6.1.0"

  # --------------------------------------------------------------------------------
  # Account Management
  # --------------------------------------------------------------------------------

  account_alias = "prod-account"

  account_pass_policy = {
    manage                         = true
    allow_users_to_change_password = true
    hard_expiry                    = false
    max_password_age               = 365
    minimum_password_length        = 8
    password_reuse_prevention      = 5
    require_lowercase_characters   = true
    require_numbers                = true
    require_symbols                = true
    require_uppercase_characters   = true
  }

  # --------------------------------------------------------------------------------
  # Account Identity provider
  # --------------------------------------------------------------------------------

  # Add a SAML provider for login
  providers_saml = [
    {
      name = "AzureAD"
      file = "path/to/azure/meta.xml"
    },
    {
      name = "ADFS"
      file = "path/to/adfs/meta.xml"
    }
  ]

  # --------------------------------------------------------------------------------
  # Policies, Groups, Users and Roles
  # --------------------------------------------------------------------------------

  # List of policies to create
  # Policies defined here can be used by name in groups, users and roles list
  policies = [
    {
      name = "ro-billing"
      path = "/assume/human/"
      desc = "Provides read-only access to billing"
      file = "policies/ro-billing.json"
      vars = {}
    },
  ]

  # List of groups to manage
  # Groups defined here can be used in users list
  groups = [
    {
      name                 = "admin-group"
      path                 = null
      policies             = []
      policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
      ]
      inline_policies      = []
    },
  ]

  # List of users to manage
  users = [
    {
      name                 = "admin"
      path                 = null
      groups               = ["admin-group"]
      access_keys          = []
      permissions_boundary = null
      policies             = []
      policy_arns          = []
      inline_policies      = []
    },
  ]

  # List of roles to manage
  roles = [
    {
      name                 = "ROLE-ADMIN"
      instance_profile     = null
      path                 = ""
      desc                 = ""
      trust_policy_file    = "trust-policies/admin.json"
      permissions_boundary = null
      policies             = []
      policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
      ]
      inline_policies      = []
    },
    {
      name                 = "ROLE-DEV"
      instance_profile     = null
      path                 = ""
      desc                 = ""
      trust_policy_file    = "trust-policies/dev.json"
      permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"
      policies = [
        "ro-billing",
      ]
      policy_arns = [
        "arn:aws:iam::aws:policy/PowerUserAccess",
      ]
      inline_policies      = []
    },
  ]

  # --------------------------------------------------------------------------------
  # Defaults
  # --------------------------------------------------------------------------------

  policy_path = "/"
  policy_desc = "Managed by Terraform"
  group_path  = "/"
  user_path   = "/"
  role_path   = "/"
  role_desc   = "Managed by Terraform"

  role_max_session_duration  = 3600
  role_force_detach_policies = true

  tags = {
    env   = "prod"
    owner = "terraform"
  }
}
```

### Use Terragrunt

Wrap this module into Terragrunt

```hcl
terraform {
  source = "github.com/Flaconi/terraform-aws-iam-roles?ref=v6.1.0"
}

inputs = {
  # --------------------------------------------------------------------------------
  # Account Management
  # --------------------------------------------------------------------------------

  account_alias = "prod-account"

  account_pass_policy = {
    manage                         = true
    allow_users_to_change_password = true
    hard_expiry                    = false
    max_password_age               = 365
    minimum_password_length        = 8
    password_reuse_prevention      = 5
    require_lowercase_characters   = true
    require_numbers                = true
    require_symbols                = true
    require_uppercase_characters   = true
  }

  # --------------------------------------------------------------------------------
  # Account Identity provider
  # --------------------------------------------------------------------------------

  # Add a SAML providers for login
  providers_saml = [
    {
      name = "AzureAD"
      file = "path/to/azure/meta.xml"
    },
    {
      name = "ADFS"
      file = "path/to/adfs/meta.xml"
    }
  ]

  # --------------------------------------------------------------------------------
  # Policies, Groups, Users and Roles
  # --------------------------------------------------------------------------------

  # List of policies to create
  # Policies defined here can be used by name in groups, users and roles list
  policies = [
    {
      name = "ro-billing"
      path = "/assume/human/"
      desc = "Provides read-only access to billing"
      file = "policies/ro-billing.json"
      vars = {}
    },
  ]

  # List of groups to manage
  # Groups defined here can be used in users list
  groups = [
    {
      name                 = "admin-group"
      path                 = null
      policies             = []
      policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
      ]
      inline_policies      = []
    },
  ]

  # List of users to manage
  users = [
    {
      name                 = "admin"
      path                 = null
      groups               = ["admin-group"]
      access_keys          = []
      permissions_boundary = null
      policies             = []
      policy_arns          = []
      inline_policies      = []
    },
  ]

  # List of roles to manage
  roles = [
    {
      name                 = "ROLE-ADMIN"
      instance_profile     = null
      path                 = ""
      desc                 = ""
      trust_policy_file    = "trust-policies/admin.json"
      permissions_boundary = null
      policies             = []
      policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
      ]
      inline_policies      = []
    },
    {
      name                 = "ROLE-DEV"
      instance_profile     = null
      path                 = ""
      desc                 = ""
      trust_policy_file    = "trust-policies/dev.json"
      permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"
      policies = [
        "ro-billing",
      ]
      policy_arns = [
        "arn:aws:iam::aws:policy/PowerUserAccess",
      ]
      inline_policies      = []
    },
  ]

  # --------------------------------------------------------------------------------
  # Defaults
  # --------------------------------------------------------------------------------

  policy_path = "/"
  policy_desc = "Managed by Terraform"
  group_path  = "/"
  user_path   = "/"
  role_path   = "/"
  role_desc   = "Managed by Terraform"

  role_max_session_duration  = 3600
  role_force_detach_policies = true

  tags = {
    env   = "prod"
    owner = "terraform"
  }
}
```

<!-- TFDOCS_HEADER_START -->


<!-- TFDOCS_HEADER_END -->

<!-- TFDOCS_PROVIDER_START -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5 |

<!-- TFDOCS_PROVIDER_END -->

<!-- TFDOCS_REQUIREMENTS_START -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5 |

<!-- TFDOCS_REQUIREMENTS_END -->

<!-- TFDOCS_INPUTS_START -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_account_alias"></a> [account\_alias](#input\_account\_alias)

Description: Assign the account alias for the AWS Account. Unmanaged by default. Resource will be created if the string is non-empty.

Type: `string`

Default: `""`

### <a name="input_account_pass_policy"></a> [account\_pass\_policy](#input\_account\_pass\_policy)

Description: Manages Password Policy for the AWS Account. Unmanaged by default. Resource will be created if 'manage' is set to true.

Type:

```hcl
object({
    manage                         = optional(bool, false) # Set to true, to manage the AWS account password policy
    allow_users_to_change_password = optional(bool)        # Allow users to change their own password?
    hard_expiry                    = optional(bool)        # Users are prevented from setting a new password after their password has expired?
    max_password_age               = optional(number)      # Number of days that an user password is valid
    minimum_password_length        = optional(number)      # Minimum length to require for user passwords
    password_reuse_prevention      = optional(number)      # The number of previous passwords that users are prevented from reusing
    require_lowercase_characters   = optional(bool)        # Require lowercase characters for user passwords?
    require_numbers                = optional(bool)        # Require numbers for user passwords?
    require_symbols                = optional(bool)        # Require symbols for user passwords?
    require_uppercase_characters   = optional(bool)        # Require uppercase characters for user passwords?
  })
```

Default: `{}`

### <a name="input_providers_saml"></a> [providers\_saml](#input\_providers\_saml)

Description: A list of dictionaries defining saml providers.

Type:

```hcl
list(object({
    name = string # The name of the provider to create
    file = string # Path to XML generated by identity provider that supports SAML 2.0
  }))
```

Default: `[]`

### <a name="input_providers_oidc"></a> [providers\_oidc](#input\_providers\_oidc)

Description: A list of dictionaries defining openid connect providers.

Type:

```hcl
list(object({
    url             = string       # URL of the identity provider. Corresponds to the iss claim
    client_id_list  = list(string) # List of client IDs (also known as audiences)
    thumbprint_list = list(string) # List of server certificate thumbprints.
  }))
```

Default: `[]`

### <a name="input_policies"></a> [policies](#input\_policies)

Description: A list of dictionaries defining all policies.

Type:

```hcl
list(object({
    name = string                    # Name of the policy
    path = optional(string)          # Defaults to 'var.policy_path' if variable is set to null
    desc = optional(string)          # Defaults to 'var.policy_desc' if variable is set to null
    file = string                    # Path to json or json.tmpl file of policy
    vars = optional(map(string), {}) # Policy template variables {key = val, ...}
  }))
```

Default: `[]`

### <a name="input_groups"></a> [groups](#input\_groups)

Description: A list of dictionaries defining all groups.

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_users"></a> [users](#input\_users)

Description: A list of dictionaries defining all users.

Type:

```hcl
list(object({
    name   = string                     # Name of the user
    path   = optional(string)           # Defaults to 'var.user_path' if variable is set to null
    groups = optional(list(string), []) # List of group names to add this user to
    access_keys = optional(list(object({
      name    = string                     # IaC identifier for first or second IAM access key (not used on AWS)
      pgp_key = optional(string)           # Leave empty for non or provide a b64-enc pubkey or keybase username
      status  = optional(string, "Active") # 'Active' or 'Inactive'
    })), [])
    permissions_boundary = optional(string)           # ARN to a policy used as permissions boundary (or null/empty)
    policies             = optional(list(string), []) # List of names of policies (must be defined in var.policies)
    policy_arns          = optional(list(string), []) # List of existing policy ARN's
    inline_policies = optional(list(object({
      name = string                    # Name of the inline policy
      file = string                    # Path to json or json.tmpl file of policy
      vars = optional(map(string), {}) # Policy template variables {key = val, ...}
    })), [])
  }))
```

Default: `[]`

### <a name="input_roles"></a> [roles](#input\_roles)

Description: A list of dictionaries defining all roles.

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_policy_path"></a> [policy\_path](#input\_policy\_path)

Description: The default path under which to create the policy if not specified in the policies list. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure.

Type: `string`

Default: `"/"`

### <a name="input_policy_desc"></a> [policy\_desc](#input\_policy\_desc)

Description: The default description of the policy.

Type: `string`

Default: `"Managed by Terraform"`

### <a name="input_group_path"></a> [group\_path](#input\_group\_path)

Description: The path under which to create the group. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure.

Type: `string`

Default: `"/"`

### <a name="input_user_path"></a> [user\_path](#input\_user\_path)

Description: The path under which to create the user. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure.

Type: `string`

Default: `"/"`

### <a name="input_role_path"></a> [role\_path](#input\_role\_path)

Description: The path under which to create the role. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure.

Type: `string`

Default: `"/"`

### <a name="input_role_desc"></a> [role\_desc](#input\_role\_desc)

Description: The description of the role.

Type: `string`

Default: `"Managed by Terraform"`

### <a name="input_role_max_session_duration"></a> [role\_max\_session\_duration](#input\_role\_max\_session\_duration)

Description: The maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours specified in seconds.

Type: `number`

Default: `3600`

### <a name="input_role_force_detach_policies"></a> [role\_force\_detach\_policies](#input\_role\_force\_detach\_policies)

Description: Specifies to force detaching any policies the role has before destroying it.

Type: `bool`

Default: `true`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Key-value mapping of tags for the IAM role or user.

Type: `map(string)`

Default: `{}`

<!-- TFDOCS_INPUTS_END -->

<!-- TFDOCS_OUTPUTS_START -->
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_alias"></a> [account\_alias](#output\_account\_alias) | Created Account alias. |
| <a name="output_account_pass_policy"></a> [account\_pass\_policy](#output\_account\_pass\_policy) | Created Account password policy. |
| <a name="output_group_inline_policy_attachments"></a> [group\_inline\_policy\_attachments](#output\_group\_inline\_policy\_attachments) | Attached group inline IAM policies |
| <a name="output_group_policy_arn_attachments"></a> [group\_policy\_arn\_attachments](#output\_group\_policy\_arn\_attachments) | Attached group IAM policy arns |
| <a name="output_group_policy_attachments"></a> [group\_policy\_attachments](#output\_group\_policy\_attachments) | Attached group customer managed IAM policies |
| <a name="output_groups"></a> [groups](#output\_groups) | Created IAM groups |
| <a name="output_policies"></a> [policies](#output\_policies) | Created customer managed IAM policies |
| <a name="output_providers_oidc"></a> [providers\_oidc](#output\_providers\_oidc) | Created OpenID Connect providers. |
| <a name="output_providers_saml"></a> [providers\_saml](#output\_providers\_saml) | Created SAML providers. |
| <a name="output_role_inline_policy_attachments"></a> [role\_inline\_policy\_attachments](#output\_role\_inline\_policy\_attachments) | Attached role inline IAM policies |
| <a name="output_role_policy_arn_attachments"></a> [role\_policy\_arn\_attachments](#output\_role\_policy\_arn\_attachments) | Attached role IAM policy arns |
| <a name="output_role_policy_attachments"></a> [role\_policy\_attachments](#output\_role\_policy\_attachments) | Attached role customer managed IAM policies |
| <a name="output_roles"></a> [roles](#output\_roles) | Created IAM roles |
| <a name="output_user_access_keys"></a> [user\_access\_keys](#output\_user\_access\_keys) | Created access keys |
| <a name="output_user_group_memberships"></a> [user\_group\_memberships](#output\_user\_group\_memberships) | Assigned user/group memberships |
| <a name="output_user_inline_policy_attachments"></a> [user\_inline\_policy\_attachments](#output\_user\_inline\_policy\_attachments) | Attached user inline IAM policies |
| <a name="output_user_policy_arn_attachments"></a> [user\_policy\_arn\_attachments](#output\_user\_policy\_arn\_attachments) | Attached user IAM policy arns |
| <a name="output_user_policy_attachments"></a> [user\_policy\_attachments](#output\_user\_policy\_attachments) | Attached user customer managed IAM policies |
| <a name="output_users"></a> [users](#output\_users) | Created IAM users |

<!-- TFDOCS_OUTPUTS_END -->


## Related projects

| GitHub | Module Registry | Description |
|--------|-----------------|-------------|
| [aws-iam][aws_iam_git_lnk]                         | [aws-iam][aws_iam_reg_lnk]                         | Manages AWS IAM to its full extend  |
| [aws-iam-roles][aws_iam_roles_git_lnk]             | [aws-iam-roles][aws_iam_roles_reg_lnk]             | Deprecated by [aws-iam][aws_iam_git_lnk] |
| [aws-iam-cross_account][aws_iam_cross_acc_git_lnk] | [aws-iam-cross-account][aws_iam_cross_acc_reg_lnk] | Deprecated by [aws-iam][aws_iam_git_lnk] |
| [aws-route53][aws_route53_git_lnk]                 | [aws-route53][aws_route53_reg_lnk]                 | Manages creation of multiple Route53 zones including attachment to new or existing delegation set |
| [aws-elb][aws_elb_git_lnk]                         | [aws-elb][aws_elb_reg_lnk]                         | Manages ELB with optionally a public and/or private Route53 DNS record attached to it |
| [aws-rds][aws_rds_git_lnk]                         | [aws-rds][aws_rds_reg_lnk]                         | Manages RDS resources on AWS |

[aws_iam_git_lnk]: https://github.com/cytopia/terraform-aws-iam
[aws_iam_reg_lnk]: https://registry.terraform.io/modules/cytopia/iam/aws

[aws_iam_roles_git_lnk]: https://github.com/cytopia/terraform-aws-iam-roles
[aws_iam_roles_reg_lnk]: https://registry.terraform.io/modules/cytopia/iam-roles/aws

[aws_iam_cross_acc_git_lnk]: https://github.com/cytopia/terraform-aws-iam-cross-account
[aws_iam_cross_acc_reg_lnk]: https://registry.terraform.io/modules/cytopia/iam-cross-account/aws

[aws_route53_git_lnk]: https://github.com/cytopia/terraform-aws-route53-zone
[aws_route53_reg_lnk]: https://registry.terraform.io/modules/cytopia/route53-zone/aws

[aws_elb_git_lnk]: https://github.com/cytopia/terraform-aws-elb
[aws_elb_reg_lnk]: https://registry.terraform.io/modules/cytopia/elb/aws

[aws_rds_git_lnk]: https://github.com/cytopia/terraform-aws-rds
[aws_rds_reg_lnk]: https://registry.terraform.io/modules/cytopia/rds/aws


## Authors

Forked from [cytopia](https://github.com/cytopia).


## License

**[MIT License](LICENSE)**

Copyright (c) 2023 **[Flaconi GmbH](https://github.com/flaconi)**
