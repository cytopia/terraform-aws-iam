# Policies with custom data sources

This example creates a policy via terraforms [`aws_iam_policy_document`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) and then adds it to a role's `policy_arns` list.


## Table of Contents

1. [Overview](#overview)
2. [Example](#example)
    - [Variable definition](#variable-definition)
    - [Use data source to fetch a dynamic value](#use-data-source-to-fetch-a-dynamic-value)
    - [Build our policy](#build-our-policy)
    - [Enrich roles list with created policy](#enrich-roles-list-with-created-policy)
    - [Define the iam module](#define-the-iam-module)
5. [Usage](#usage)
6. [Requirements](#requirements)
7. [Providers](#providers)
8. [Inputs](#inputs)
9. [Outputs](#outputs)


## Overview

By using [`aws_iam_policy_document`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) you have the advantage to use terraform's variables inside the policy definition and be able to first gather already existing resources and add them to that policy. This makes the process of creating policies as dynamic and flexible as it can get.


## Example

The following defines two roles, both without any policy attached.

#### Variable definition

`terraform.tfvars`
```hcl
roles = [
  {
    name                 = "ROLE-ADMIN"
    path                 = null
    desc                 = null
    trust_policy_file    = "data/trust-policy-file.json"
    permissions_boundary = null
    policies             = []
    inline_policies      = []
    policy_arns          = []
  },
  {
    name                 = "ROLE-DEV"
    path                 = null
    desc                 = null
    trust_policy_file    = "data/trust-policy-file.json"
    permissions_boundary = null
    policies             = []
    inline_policies      = []
    policy_arns          = []
  },
]
```

#### Use data source to fetch a dynamic value

Now we're going to dynamically fetch the current AWS account id (just for the sake of this example to have something dynamic).

`main.tf`
```hcl
data "aws_caller_identity" "current" {}
```

#### Build our policy

We can then use this account id and include it in our policy document.

`main.tf`
```hcl
data "aws_iam_policy_document" "s3" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
    ]

    resources = [
      "arn:aws:s3::${data.aws_caller_identity.current.account_id}:*",
    ]
  }
}
```

Based on the created policy document, we can define our policy.

`main.tf`
```hcl
resource "aws_iam_policy" "s3" {
  name        = "s3-policy"
  path        = "/custom/"
  description = "Custom S3 policy"
  policy      = data.aws_iam_policy_document.s3.json

  lifecycle {
    create_before_destroy = true
  }
}
```

#### Enrich roles list with created policy

We can now enrich the roles list and add this policy to `ROLE-ADMIN`.
We do this by creating a local with the exact same structure and use a condition to attach it to the specific role.

`main.tf`
```hcl
locals {
  # Roles in this list will have the custom policy added to its policy_arns list
  roles_enriched = [
    for role in var.roles : {
      name                 = role.name
      path                 = role.path
      desc                 = role.desc
      trust_policy_file    = role.trust_policy_file
      permissions_boundary = role.permissions_boundary
      policies             = role.policies
      inline_policies      = role.inline_policies
      policy_arns          = concat(role.policy_arns, [aws_iam_policy.s3.arn])
    } if role["name"] == "ROLE-ADMIN"
  ]

  # Roles in this list will be left as they were (condition reversed)
  roles_default = [
    for role in var.roles : {
      name                 = role.name
      path                 = role.path
      desc                 = role.desc
      trust_policy_file    = role.trust_policy_file
      permissions_boundary = role.permissions_boundary
      policies             = role.policies
      inline_policies      = role.inline_policies
      policy_arns          = role.policy_arns
    } if role["name"] != "ROLE-ADMIN"
  ]

  # Let's merge both created lists
  roles = concat(local.roles_enriched, local.roles_default)
}
```

#### Define the iam module

Now we add everything together and use the iam module

`main.tf`
```hcl
module "aws_iam" {
  source = "github.com/cytopia/terraform-aws-iam?ref=v5.0.4"

  # Note: we're using the local here as input instead
  roles = local.roles
}
```


## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run terraform destroy when you don't need these resources.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_iam"></a> [aws\_iam](#module\_aws\_iam) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_alias"></a> [account\_alias](#input\_account\_alias) | Assign the account alias for the AWS Account. Unmanaged by default. Resource will be created if the string is non-empty. | `string` | `""` | no |
| <a name="input_account_pass_policy"></a> [account\_pass\_policy](#input\_account\_pass\_policy) | Manages Password Policy for the AWS Account. Unmanaged by default. Resource will be created if 'manage' is set to true. | <pre>object({<br>    manage                         = optional(bool, false) # Set to true, to manage the AWS account password policy<br>    allow_users_to_change_password = optional(bool)        # Allow users to change their own password?<br>    hard_expiry                    = optional(bool)        # Users are prevented from setting a new password after their password has expired?<br>    max_password_age               = optional(number)      # Number of days that an user password is valid<br>    minimum_password_length        = optional(number)      # Minimum length to require for user passwords<br>    password_reuse_prevention      = optional(number)      # The number of previous passwords that users are prevented from reusing<br>    require_lowercase_characters   = optional(bool)        # Require lowercase characters for user passwords?<br>    require_numbers                = optional(bool)        # Require numbers for user passwords?<br>    require_symbols                = optional(bool)        # Require symbols for user passwords?<br>    require_uppercase_characters   = optional(bool)        # Require uppercase characters for user passwords?<br>  })</pre> | `{}` | no |
| <a name="input_providers_saml"></a> [providers\_saml](#input\_providers\_saml) | A list of dictionaries defining saml providers. | <pre>list(object({<br>    name = string # The name of the provider to create<br>    file = string # Path to XML generated by identity provider that supports SAML 2.0<br>  }))</pre> | `[]` | no |
| <a name="input_providers_oidc"></a> [providers\_oidc](#input\_providers\_oidc) | A list of dictionaries defining openid connect providers. | <pre>list(object({<br>    url             = string       # URL of the identity provider. Corresponds to the iss claim<br>    client_id_list  = list(string) # List of client IDs (also known as audiences)<br>    thumbprint_list = list(string) # List of server certificate thumbprints.<br>  }))</pre> | `[]` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | A list of dictionaries defining all policies. | <pre>list(object({<br>    name = string                    # Name of the policy<br>    path = optional(string)          # Defaults to 'var.policy_path' if variable is set to null<br>    desc = optional(string)          # Defaults to 'var.policy_desc' if variable is set to null<br>    file = string                    # Path to json or json.tmpl file of policy<br>    vars = optional(map(string), {}) # Policy template variables {key = val, ...}<br>  }))</pre> | `[]` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | A list of dictionaries defining all groups. | <pre>list(object({<br>    name        = string                     # Name of the group<br>    path        = optional(string)           # Defaults to 'var.group_path' if variable is set to null<br>    policies    = optional(list(string), []) # List of names of policies (must be defined in var.policies)<br>    policy_arns = optional(list(string), []) # List of existing policy ARN's<br>    inline_policies = optional(list(object({<br>      name = string                    # Name of the inline policy<br>      file = string                    # Path to json or json.tmpl file of policy<br>      vars = optional(map(string), {}) # Policy template variables {key = val, ...}<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_users"></a> [users](#input\_users) | A list of dictionaries defining all users. | <pre>list(object({<br>    name   = string                     # Name of the user<br>    path   = optional(string)           # Defaults to 'var.user_path' if variable is set to null<br>    groups = optional(list(string), []) # List of group names to add this user to<br>    access_keys = optional(list(object({<br>      name    = string                     # IaC identifier for first or second IAM access key (not used on AWS)<br>      pgp_key = optional(string)           # Leave empty for non or provide a b64-enc pubkey or keybase username<br>      status  = optional(string, "Active") # 'Active' or 'Inactive'<br>    })), [])<br>    permissions_boundary = optional(string)           # ARN to a policy used as permissions boundary (or null/empty)<br>    policies             = optional(list(string), []) # List of names of policies (must be defined in var.policies)<br>    policy_arns          = optional(list(string), []) # List of existing policy ARN's<br>    inline_policies = optional(list(object({<br>      name = string                    # Name of the inline policy<br>      file = string                    # Path to json or json.tmpl file of policy<br>      vars = optional(map(string), {}) # Policy template variables {key = val, ...}<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | A list of dictionaries defining all roles. | <pre>list(object({<br>    name                 = string                     # Name of the role<br>    instance_profile     = optional(string)           # Name of the instance profile<br>    path                 = optional(string)           # Defaults to 'var.role_path' if variable is set to null<br>    desc                 = optional(string)           # Defaults to 'var.role_desc' if variable is set to null<br>    trust_policy_file    = string                     # Path to file of trust/assume policy. Will be templated if vars are passed.<br>    trust_policy_vars    = optional(map(string), {})  # Policy template variables {key = val, ...}<br>    permissions_boundary = optional(string)           # ARN to a policy used as permissions boundary (or null/empty)<br>    policies             = optional(list(string), []) # List of names of policies (must be defined in var.policies)<br>    policy_arns          = optional(list(string), []) # List of existing policy ARN's<br>    inline_policies = optional(list(object({<br>      name = string                    # Name of the inline policy<br>      file = string                    # Path to json or json.tmpl file of policy<br>      vars = optional(map(string), {}) # Policy template variables {key = val, ...}<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_policy_path"></a> [policy\_path](#input\_policy\_path) | The default path under which to create the policy if not specified in the policies list. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure. | `string` | `"/"` | no |
| <a name="input_policy_desc"></a> [policy\_desc](#input\_policy\_desc) | The default description of the policy. | `string` | `"Managed by Terraform"` | no |
| <a name="input_group_path"></a> [group\_path](#input\_group\_path) | The path under which to create the group. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure. | `string` | `"/"` | no |
| <a name="input_user_path"></a> [user\_path](#input\_user\_path) | The path under which to create the user. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure. | `string` | `"/"` | no |
| <a name="input_role_path"></a> [role\_path](#input\_role\_path) | The path under which to create the role. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure. | `string` | `"/"` | no |
| <a name="input_role_desc"></a> [role\_desc](#input\_role\_desc) | The description of the role. | `string` | `"Managed by Terraform"` | no |
| <a name="input_role_max_session_duration"></a> [role\_max\_session\_duration](#input\_role\_max\_session\_duration) | The maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours specified in seconds. | `number` | `3600` | no |
| <a name="input_role_force_detach_policies"></a> [role\_force\_detach\_policies](#input\_role\_force\_detach\_policies) | Specifies to force detaching any policies the role has before destroying it. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value mapping of tags for the IAM role or user. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_roles"></a> [roles](#output\_roles) | Created roles |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
