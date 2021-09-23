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


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

The following requirements are needed by this module:

- terraform (>= 0.12.26)

- aws (>= 3)

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


<!-- TFDOCS_INPUTS_START -->
## Required Inputs

No required input.

## Optional Inputs

The following input variables are optional (have default values):

### account\_alias

Description: Assign the account alias for the AWS Account. Unmanaged by default. Resource will be created if the string is non-empty.

Type: `string`

Default: `""`

### account\_pass\_policy

Description: Manages Password Policy for the AWS Account. Unmanaged by default. Resource will be created if 'manage' is set to true.

Type:

```hcl
object({
    manage                         = bool   # Set to true, to manage the AWS account password policy
    allow_users_to_change_password = bool   # Allow users to change their own password?
    hard_expiry                    = bool   # Users are prevented from setting a new password after their password has expired?
    max_password_age               = number # Number of days that an user password is valid
    minimum_password_length        = number # Minimum length to require for user passwords
    password_reuse_prevention      = number # The number of previous passwords that users are prevented from reusing
    require_lowercase_characters   = bool   # Require lowercase characters for user passwords?
    require_numbers                = bool   # Require numbers for user passwords?
    require_symbols                = bool   # Require symbols for user passwords?
    require_uppercase_characters   = bool   # Require uppercase characters for user passwords?
  })
```

Default:

```json
{
  "allow_users_to_change_password": null,
  "hard_expiry": null,
  "manage": false,
  "max_password_age": null,
  "minimum_password_length": null,
  "password_reuse_prevention": null,
  "require_lowercase_characters": null,
  "require_numbers": null,
  "require_symbols": null,
  "require_uppercase_characters": null
}
```

### providers\_saml

Description: A list of dictionaries defining saml providers.

Type:

```hcl
list(object({
    name = string # The name of the provider to create
    file = string # Path to XML generated by identity provider that supports SAML 2.0
  }))
```

Default: `[]`

### providers\_oidc

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

### policies

Description: A list of dictionaries defining all policies.

Type:

```hcl
list(object({
    name = string      # Name of the policy
    path = string      # Defaults to 'var.policy_path' if variable is set to null
    desc = string      # Defaults to 'var.policy_desc' if variable is set to null
    file = string      # Path to json or json.tmpl file of policy
    vars = map(string) # Policy template variables {key: val, ...}
  }))
```

Default: `[]`

### groups

Description: A list of dictionaries defining all groups.

Type:

```hcl
list(object({
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
```

Default: `[]`

### users

Description: A list of dictionaries defining all users.

Type:

```hcl
list(object({
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
```

Default: `[]`

### roles

Description: A list of dictionaries defining all roles.

Type:

```hcl
list(object({
    name                 = string       # Name of the role
    instance_profile     = string       # Name of the instance profile
    path                 = string       # Defaults to 'var.role_path' if variable is set to null
    desc                 = string       # Defaults to 'var.role_desc' if variable is set to null
    trust_policy_file    = string       # Path to file of trust/assume policy. Will be templated if vars are passed.
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
```

Default: `[]`

### policy\_path

Description: The default path under which to create the policy if not specified in the policies list. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure.

Type: `string`

Default: `"/"`

### policy\_desc

Description: The default description of the policy.

Type: `string`

Default: `"Managed by Terraform"`

### group\_path

Description: The path under which to create the group. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure.

Type: `string`

Default: `"/"`

### user\_path

Description: The path under which to create the user. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure.

Type: `string`

Default: `"/"`

### role\_path

Description: The path under which to create the role. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure.

Type: `string`

Default: `"/"`

### role\_desc

Description: The description of the role.

Type: `string`

Default: `"Managed by Terraform"`

### role\_max\_session\_duration

Description: The maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours specified in seconds.

Type: `number`

Default: `3600`

### role\_force\_detach\_policies

Description: Specifies to force detaching any policies the role has before destroying it.

Type: `bool`

Default: `true`

### tags

Description: Key-value mapping of tags for the IAM role or user.

Type: `map(any)`

Default: `{}`

<!-- TFDOCS_INPUTS_END -->


<!-- TFDOCS_OUTPUTS_START -->
## Outputs

| Name | Description |
|------|-------------|
| account\_alias | Created Account alias. |
| account\_pass\_policy | Created Account password policy. |
| debug\_local\_group\_inline\_policies | The transformed group inline policy map |
| debug\_local\_group\_policies | The transformed group policy map |
| debug\_local\_group\_policy\_arns | The transformed group policy arns map |
| debug\_local\_policies | The transformed policy map |
| debug\_local\_role\_inline\_policies | The transformed role inline policy map |
| debug\_local\_role\_policies | The transformed role policy map |
| debug\_local\_role\_policy\_arns | The transformed role policy arns map |
| debug\_local\_user\_access\_keys | The transformed user access key map |
| debug\_local\_user\_inline\_policies | The transformed user inline policy map |
| debug\_local\_user\_policies | The transformed user policy map |
| debug\_local\_user\_policy\_arns | The transformed user policy arns map |
| debug\_var\_groups | The defined groups list |
| debug\_var\_policies | The transformed policy map |
| debug\_var\_roles | The defined roles list |
| debug\_var\_users | The defined users list |
| group\_inline\_policy\_attachments | Attached group inline IAM policies |
| group\_policy\_arn\_attachments | Attached group IAM policy arns |
| group\_policy\_attachments | Attached group customer managed IAM policies |
| groups | Created IAM groups |
| policies | Created customer managed IAM policies |
| providers\_oidc | Created OpenID Connect providers. |
| providers\_saml | Created SAML providers. |
| role\_inline\_policy\_attachments | Attached role inline IAM policies |
| role\_policy\_arn\_attachments | Attached role IAM policy arns |
| role\_policy\_attachments | Attached role customer managed IAM policies |
| roles | Created IAM roles |
| user\_group\_memberships | Assigned user/group memberships |
| user\_inline\_policy\_attachments | Attached user inline IAM policies |
| user\_policy\_arn\_attachments | Attached user IAM policy arns |
| user\_policy\_attachments | Attached user customer managed IAM policies |
| users | Created IAM users |

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

Module managed by [cytopia](https://github.com/cytopia).


## License

**[MIT License](LICENSE)**

Copyright (c) 2018 **[cytopia](https://github.com/cytopia)**
