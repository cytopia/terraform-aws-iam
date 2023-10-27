# Groups

This example creates policies and various different groups.


## Overview

You can define as many groups as desired and reference them by their names in **[`var.users`](../users/)** in order to attach as many groups to a specific user as needed.
* When using the `policies` key, respective policies must be defined in **[`var.policies`](../policies/)**.


## Examples

**Note:** The following example only shows the creation of a single group.
You can however create as many groups as desired. Also re-arranging them within the list will not
trigger terraform to change or destroy resources as they're internally stored in a map (rather than a list) by their group names as keys (See module's `locals.tf` for transformation).

Groups are defined as follows:

`terraform.tfvars`
```hcl
groups = [
  {
    name       = "group-name" # Name of the group (reference this in var.users for attachment)
    path       = "/path/"     # Defaults to 'var.group_path' if variable is set to null
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

If you want to attach dynamic policies created via [`aws_iam_policy_document`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document). Have a look at this **[Example](../policies-with-custom-data-sources)**.


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
| <a name="input_groups"></a> [groups](#input\_groups) | A list of dictionaries defining all groups. | <pre>list(object({<br>    name        = string                     # Name of the group<br>    path        = optional(string)           # Defaults to 'var.group_path' if variable is set to null<br>    policies    = optional(list(string), []) # List of names of policies (must be defined in var.policies)<br>    policy_arns = optional(list(string), []) # List of existing policy ARN's<br>    inline_policies = optional(list(object({<br>      name = string                    # Name of the inline policy<br>      file = string                    # Path to json or json.tmpl file of policy<br>      vars = optional(map(string), {}) # Policy template variables {key = val, ...}<br>    })), [])<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policies"></a> [policies](#output\_policies) | Created customer managed IAM policies |
| <a name="output_groups"></a> [groups](#output\_groups) | Created groups |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
