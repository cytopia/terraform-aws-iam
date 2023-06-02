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

Defined policies can be used to be attached to **[`var.groups`](../groups/)**, **[`var.users`](../users/)** and/or **[`var.roles`](../roles/)** by this module.


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

```bash
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

**Yes!** See the following example for how to achieve this **[Policies with custom data sources](../policies-with-custom-data-sources)**


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

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_iam"></a> [aws\_iam](#module\_aws\_iam) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_policies"></a> [policies](#input\_policies) | A list of dictionaries defining all policies. | <pre>list(object({<br>    name = string                    # Name of the policy<br>    path = optional(string)          # Defaults to 'var.policy_path' if variable is set to null<br>    desc = optional(string)          # Defaults to 'var.policy_desc' if variable is set to null<br>    file = string                    # Path to json or json.tmpl file of policy<br>    vars = optional(map(string), {}) # Policy template variables {key = val, ...}<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policies"></a> [policies](#output\_policies) | Created customer managed IAM policies |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
