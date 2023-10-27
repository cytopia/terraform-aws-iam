# Users

This example creates policies and various different users.


## Overview

You can define as many users as desired.
* When using the `groups` key, respective groups must be defined in **[`var.groups`](../groups/)**.
* When using the `policies` key, respective policies must be defined in **[`var.policies`](../policies/)**.


## Examples

**Note:** The following examples only shows the creation of a single user. You can however create as many users as desired. Also re-arranging them within the list will not trigger terraform to change or destroy resources as they're internally stored in a map (rather than a list) by their user names as keys (See module's `locals.tf` for transformation).

Users are defined as follows:

`terraform.tfvars`
```hcl
users = [
  {
    name     = "username-1"  # Name of the user
    path     = "/path/"      # Defaults to 'var.user_path' if variable is set to null
    groups   = [
      "group-name-1",        # group-name-1 must be defined in var.groups
      "group-name-2",        # group-name-1 must be defined in var.groups
    ]
    access_keys = [          # You can create up to two access keys
      {
        name    = "key-1"
        pgp_key = ""
        status  = "Inactive"
      },
      {
        name    = "key-2"
        pgp_key = ""
        status  = "Active"
      },
    ]
    permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"
    policies   = [
      "policy-name-1",        # policy-name-1 must be defined in var.policies
      "policy-name-2",        # policy-name-2 must be defined in var.policies
    ]
    policy_arns = [           # Attach policies by ARN
      "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
      "arn:aws:iam::aws:policy/AWSResourceAccessManagerFullAccess",
    ]
    inline_policies = [       # Attach inline policies defined via JSON files
      {
        name = "inline-policy-1"
        file = "data/policies/kms-ro.json"
        vars = {}
      },
      {
        name = "inline-policy-2"
        file = "data/policies/sqs-ro.json.tmpl"
        vars = {  # You can use variables inside JSON files
          var1 = "Some value",
          var2 = "Another value",
        }
      },
    ]
  },
]
```

If you want to attach dyamic policies created via [`aws_iam_policy_document`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document). Have a look at this **[Example](../policies-with-custom-data-sources)**.


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
| <a name="input_policies"></a> [policies](#input\_policies) | A list of dictionaries defining all policies. | <pre>list(object({<br>    name = string      # Name of the policy<br>    path = string      # Defaults to 'var.policy_path' if variable is set to null<br>    desc = string      # Defaults to 'var.policy_desc' if variable is set to null<br>    file = string      # Path to json or json.tmpl file of policy<br>    vars = map(string) # Policy template variables {key: val, ...}<br>  }))</pre> | `[]` | no |
| <a name="input_users"></a> [users](#input\_users) | A list of dictionaries defining all users. | <pre>list(object({<br>    name   = string       # Name of the user<br>    path   = string       # Defaults to 'var.user_path' if variable is set to null<br>    groups = list(string) # List of group names to add this user to<br>    access_keys = list(object({<br>      name    = string # IaC identifier for first or second IAM access key (not used on AWS)<br>      pgp_key = string # Leave empty for non or provide a b64-enc pubkey or keybase username<br>      status  = string # 'Active' or 'Inactive'<br>    }))<br>    permissions_boundary = string       # ARN to a policy used as permissions boundary (or null/empty)<br>    policies             = list(string) # List of names of policies (must be defined in var.policies)<br>    policy_arns          = list(string) # List of existing policy ARN's<br>    inline_policies = list(object({<br>      name = string      # Name of the inline policy<br>      file = string      # Path to json or json.tmpl file of policy<br>      vars = map(string) # Policy template variables {key = val, ...}<br>    }))<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policies"></a> [policies](#output\_policies) | Created customer managed IAM policies |
| <a name="output_users"></a> [users](#output\_users) | Created users |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
