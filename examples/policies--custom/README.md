# Custom policies

This example creates two policies on AWS. One simple JSON file and one with variable interpolations.

## Table of Contents

1. [Overview](#overview)
2. [Examples](#examples)
    - [Simple policy](#simple-policy)
    - [Policy with variables](#policy-with-variables)
3. [Organizing policy files](#organizing-policy-files)
4. [Use `aws_iam_policy_document` to define policies](#use-aws_iam_policy_document-to-define-policies)
5. [Usage](#usage)
6. [Requirements](#requirements)
7. [Providers](#providers)
8. [Inputs](#inputs)
9. [Outputs](#outputs)


## Overview

Defined policies can be used to be attached to `groups`, `users` and/or `roles` by this module.


## Examples

**Note:** The following examples only shows the creation of a single policy each.
You can however create as many policies as desired. Also re-arranging them within the list will not
trigger terraform to change or destroy resources as they're internally stored in a map (rather than a list) by their policy names as keys (See module's `locals.tf` for transformation).

### Simple policy

The following defines a policy named `billing-ro` created under the path `/assume/`.
The policy definition can be seen in the JSON file below.

`terraform.tfvars`
```hcl
policies = [
  {
    name = "billing-ro"
    path = "/assume/"
    desc = "Provides read-only access to billing"
    file = "data/policies/billing-ro.json"
    vars = {}
  }
]
```

`data/policies/billing-ro.json`
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BillingReadOnly",
      "Effect": "Allow",
      "Action": [
        "account:ListRegions",
        "aws-portal:View*",
        "awsbillingconsole:View*",
        "budgets:View*",
        "ce:Get*",
        "cur:Describe*",
        "pricing:Describe*",
        "pricing:Get*"
      ],
      "Resource": "*"
    }
  ]
}
```

### Policy with variables

The following policy allows to have variables in its json definition which might come in handy
to define a single policy file, which can be used across multiple AWS accounts.

The variable part will be `aws_account_id` which can differ in each environment, while still using the same policy file.

`terraform.tfvars`
```hcl
policies = [
  {
    name = "rds-authenticate"
    path = "/assume/"
    desc = "Allow user to authenticate to RDS via IAM"
    file = "data/policies/rds-authenticate.json.tmpl"
    vars = {
      aws_account_id = "1234567890",
    }
  }
]
```

Terraform will automatically substitute the `aws_account_id` variable below with the corresponding value.

`data/policies/rds-authenticate.json.tmpl`
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RDSAuthenticationAllow",
      "Effect": "Allow",
      "Action": [
        "rds-db:connect"
      ],
      "Resource": [
        "arn:aws:rds-db:eu-central-1:${aws_account_id}:dbuser:*/iam_user_rw",
        "arn:aws:rds-db:eu-central-1:${aws_account_id}:dbuser:*/iam_user_ro"
      ]
    }
  ]
}
```

## Organizing policy files

I would recommend to keep all policies at a single place of truth and have them defined in various sub directories depending if they are generic or specific.

```
.
└── policies
    ├── account-dev
    │   ├── user-developer.json
    │   ├── user-devops.json
    │   └── user-manager.json
    ├── account-prod
    │   ├── user-developer.json
    │   ├── user-devops.json
    │   └── user-manager.json
    └── generic
        ├── billing-ro.json
        ├── iam-create-service-role.json
        ├── kms-ro.json
        ├── kms-rw.json
        ├── rds-authenticate.json
        ├── sns-ro.json
        ├── sns-rw.json
        ├── sqs-ro.json
        └── sqs-rw.json
```

You can then simply symlink the `policies/` directory into each of your environments terraform or terragrunt directories.



## Use `aws_iam_policy_document` to define policies

Using JSON policies with variables offers some sort of flexibility, but terraform's data source [`aws_iam_policy_document`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) offers even more flexibility, as you can gather specific resources first and then use them within the policy definition.

So is it possible to also define policies with [`aws_iam_policy_document`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) and then attach them to groups, users and/or roles in this module?

Yes! See the following example for how to achieve this **[Enrich roles list](../complex--enrich_roles)**


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

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_alias | Assign the account alias for the AWS Account. Unmanaged by default. Resource will be created if the string is non-empty. | `string` | `""` | no |
| account\_pass\_policy | Manages Password Policy for the AWS Account. Unmanaged by default. Resource will be created if 'manage' is set to true. | <pre>object({<br>    manage                         = bool   # Set to true, to manage the AWS account password policy<br>    allow_users_to_change_password = bool   # Allow users to change their own password?<br>    hard_expiry                    = bool   # Users are prevented from setting a new password after their password has expired?<br>    max_password_age               = number # Number of days that an user password is valid<br>    minimum_password_length        = number # Minimum length to require for user passwords<br>    password_reuse_prevention      = number # The number of previous passwords that users are prevented from reusing<br>    require_lowercase_characters   = bool   # Require lowercase characters for user passwords?<br>    require_numbers                = bool   # Require numbers for user passwords?<br>    require_symbols                = bool   # Require symbols for user passwords?<br>    require_uppercase_characters   = bool   # Require uppercase characters for user passwords?<br>  })</pre> | <pre>{<br>  "allow_users_to_change_password": null,<br>  "hard_expiry": null,<br>  "manage": false,<br>  "max_password_age": null,<br>  "minimum_password_length": null,<br>  "password_reuse_prevention": null,<br>  "require_lowercase_characters": null,<br>  "require_numbers": null,<br>  "require_symbols": null,<br>  "require_uppercase_characters": null<br>}</pre> | no |
| providers\_saml | A list of dictionaries defining saml providers. | <pre>list(object({<br>    name = string # The name of the provider to create<br>    file = string # Path to XML generated by identity provider that supports SAML 2.0<br>  }))</pre> | `[]` | no |
| providers\_oidc | A list of dictionaries defining openid connect providers. | <pre>list(object({<br>    url             = string       # URL of the identity provider. Corresponds to the iss claim<br>    client_id_list  = list(string) # List of client IDs (also known as audiences)<br>    thumbprint_list = list(string) # List of server certificate thumbprints.<br>  }))</pre> | `[]` | no |
| policies | A list of dictionaries defining all policies. | <pre>list(object({<br>    name = string      # Name of the policy<br>    path = string      # Defaults to 'var.policy_path' variable is set to null<br>    desc = string      # Defaults to 'var.policy_desc' variable is set to null<br>    file = string      # Path to json or json.tmpl file of policy<br>    vars = map(string) # Policy template variables {key: val, ...}<br>  }))</pre> | `[]` | no |
| groups | A list of dictionaries defining all groups. | <pre>list(object({<br>    name        = string       # Name of the group<br>    path        = string       # Defaults to 'var.group_path' if variable is set to null<br>    policies    = list(string) # List of names of policies (must be defined in var.policies)<br>    policy_arns = list(string) # List of existing policy ARN's<br>    inline_policies = list(object({<br>      name = string      # Name of the inline policy<br>      file = string      # Path to json or json.tmpl file of policy<br>      vars = map(string) # Policy template variables {key = val, ...}<br>    }))<br>  }))</pre> | `[]` | no |
| users | A list of dictionaries defining all users. | <pre>list(object({<br>    name   = string       # Name of the user<br>    path   = string       # Defaults to 'var.user_path' variable is set to null<br>    groups = list(string) # List of group names to add this user to<br>    access_keys = list(object({<br>      name    = string # IaC identifier for first or second IAM access key (not used on AWS)<br>      pgp_key = string # Leave empty for non or provide a b64-enc pubkey or keybase username<br>      status  = string # 'Active' or 'Inactive'<br>    }))<br>    permissions_boundary = string       # ARN to a policy used as permissions boundary (or null/empty)<br>    policies             = list(string) # List of names of policies (must be defined in var.policies)<br>    policy_arns          = list(string) # List of existing policy ARN's<br>    inline_policies = list(object({<br>      name = string      # Name of the inline policy<br>      file = string      # Path to json or json.tmpl file of policy<br>      vars = map(string) # Policy template variables {key = val, ...}<br>    }))<br>  }))</pre> | `[]` | no |
| roles | A list of dictionaries defining all roles. | <pre>list(object({<br>    name                 = string       # Name of the role<br>    path                 = string       # Defaults to 'var.role_path' variable is set to null<br>    desc                 = string       # Defaults to 'var.role_desc' variable is set to null<br>    trust_policy_file    = string       # Path to file of trust/assume policy<br>    permissions_boundary = string       # ARN to a policy used as permissions boundary (or null/empty)<br>    policies             = list(string) # List of names of policies (must be defined in var.policies)<br>    policy_arns          = list(string) # List of existing policy ARN's<br>    inline_policies = list(object({<br>      name = string      # Name of the inline policy<br>      file = string      # Path to json or json.tmpl file of policy<br>      vars = map(string) # Policy template variables {key = val, ...}<br>    }))<br>  }))</pre> | `[]` | no |
| policy\_path | The default path under which to create the policy if not specified in the policies list. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure. | `string` | `"/"` | no |
| policy\_desc | The default description of the policy. | `string` | `"Managed by Terraform"` | no |
| group\_path | The path under which to create the group. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure. | `string` | `"/"` | no |
| user\_path | The path under which to create the user. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure. | `string` | `"/"` | no |
| role\_path | The path under which to create the role. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure. | `string` | `"/"` | no |
| role\_desc | The description of the role. | `string` | `"Managed by Terraform"` | no |
| role\_max\_session\_duration | The maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours specified in seconds. | `string` | `"3600"` | no |
| role\_force\_detach\_policies | Specifies to force detaching any policies the role has before destroying it. | `bool` | `true` | no |
| tags | Key-value mapping of tags for the IAM role or user. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| policies | Created customer managed IAM policies |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
