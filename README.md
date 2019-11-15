# Terraform module: AWS IAM Roles

[![Build Status](https://travis-ci.org/cytopia/terraform-aws-iam-roles.svg?branch=master)](https://travis-ci.org/cytopia/terraform-aws-iam-roles)
[![Tag](https://img.shields.io/github/tag/cytopia/terraform-aws-iam-roles.svg)](https://github.com/cytopia/terraform-aws-iam-roles/releases)
[![Terraform](https://img.shields.io/badge/Terraform--registry-aws--iam--roles-brightgreen.svg)](https://registry.terraform.io/modules/cytopia/iam-roles/aws/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This Terraform module can create an arbitrary number of IAM roles with policies and trusted
entities defined as JSON or templatable json files files.


## Usage

### Assumeable roles

```hcl
module "iam_roles" {
  source = "github.com/cytopia/terraform-aws-iam-roles?ref=v2.0.0"

  # List of policies to create
  policies = [
    {
      name = "ro-billing"
      path = "/assume/human/"
      desc = "Provides read-only access to billing"
      file = "policies/ro-billing.json"
      vars = {}
    },
  ]

  # Map of permissions boundaries to attach to specific roles
  permissions_boundaries = {
    "ROLE-DEV" = "arn:aws:iam::*:policy/perm-boundaries/default"
  }

  # List of roles to manage
  roles = [
    {
      name              = "ROLE-ADMIN"
      path              = ""
      desc              = ""
      trust_policy_file = "trust-policies/admin.json"
      policies          = []
      inline_policies   = []
      policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
      ]
    },
    {
      name              = "ROLE-DEV"
      path              = ""
      desc              = ""
      trust_policy_file = "trust-policies/dev.json"
      policies = [
        "ro-billing",
      ]
      inline_policies = []
      policy_arns = [
        "arn:aws:iam::aws:policy/PowerUserAccess",
      ]
    },
  ]

}
```

**`trust-policies/admin.json`**

Defines the permissions (Authorization)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": [
          "arn:aws:iam::1234567:role/federation/LOGIN-ADMIN"
        ]
      },
      "Condition": {}
    }
  ]
}
```
**`trust-policies/dev.json`**

Defines the permissions (Authorization)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": [
          "arn:aws:iam::1234567:role/federation/LOGIN-DEV",
          "arn:aws:iam::1234567:role/federation/LOGIN-ADMIN"
        ]
      },
      "Condition": {}
    }
  ]
}
```


**`policies/ro-billing.json`**
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


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| roles | A list of dictionaries defining all roles. | object | n/a | yes |
| force\_detach\_policies | Specifies to force detaching any policies the role has before destroying it. | string | `"true"` | no |
| max\_session\_duration | The maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours specified in seconds. | string | `"3600"` | no |
| permissions\_boundaries | A map of strings containing ARN's of policies to attach as permissions boundaries to roles. | map(string) | `{}` | no |
| policies | A list of dictionaries defining all roles. | object | `[]` | no |
| policy\_desc | The default description of the policy. | string | `"Managed by Terraform"` | no |
| policy\_path | The default path under which to create the policy if not specified in the policies list. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division_abc/subdivision_xyz/product_1234/engineering/ to match your company's organizational structure. | string | `"/"` | no |
| role\_desc | The description of the role. | string | `"Managed by Terraform"` | no |
| role\_path | The path under which to create the role. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division_abc/subdivision_xyz/product_1234/engineering/ to match your company's organizational structure. | string | `"/"` | no |
| tags | Key-value mapping of tags for the IAM role. | map | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| created\_inline\_policy\_attachments | Attached inline IAM policies |
| created\_policies | Created customer managed IAM policies |
| created\_policy\_arn\_attachments | Attached IAM policy arns |
| created\_policy\_attachments | Attached customer managed IAM policies |
| created\_roles | Created IAM roles |
| local\_inline\_policies | The transformed inline policy map |
| local\_policies | The transformed policy map |
| local\_policy\_arns | The transformed policy arns map |
| local\_role\_policies | The transformed role policy map |
| var\_permissions\_boundaries | The defined roles list |
| var\_policies | The transformed policy map |
| var\_roles | The defined roles list |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module managed by [cytopia](https://github.com/cytopia).


## License

[MIT License](LICENSE)

Copyright (c) 2018 [cytopia](https://github.com/cytopia)
