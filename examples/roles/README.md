# Roles

This example creates policies and various different roles.


## Overview

Roles must be *assumed*. The AWS resource which is allowed to assume a specific role has to be defined on a per role base via its `trust_policy_file`.

* When using the `policies` key, respective policies must be defined in **[`var.policies`](../policies/)**.


## Examples

**Note:** The following examples only shows the creation of a single role each.
You can however create as many roles as desired. Also re-arranging them within the list will not
trigger terraform to change or destroy resources as they're internally stored in a map (rather than a list) by their role names as keys (See module's `locals.tf` for transformation).

### Role assumed by another role

The following defined role has administrator access on the provisioned AWS account.

`terraform.tfvars`
```hcl
roles = [
  {
    name                 = "ROLE-ADMIN"
    instance_profile     = null
    path                 = null
    desc                 = null
    trust_policy_file    = "data/trust-policies/admin.json"
    permissions_boundary = null
    policies             = []
    inline_policies      = []
    policy_arns          = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  },
]
```

The following trust policy allows to assume the above defined role, from a role named `LOGIN-ADMIN` in the AWS account `1234567890`.

`data/trust-policies/admin.json`
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": [
          "arn:aws:iam::1234567890:role/federation/LOGIN-ADMIN"
        ]
      },
      "Condition": {}
    }
  ]
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
| <a name="input_roles"></a> [roles](#input\_roles) | A list of dictionaries defining all roles. | <pre>list(object({<br>    name                 = string                     # Name of the role<br>    instance_profile     = optional(string)           # Name of the instance profile<br>    path                 = optional(string)           # Defaults to 'var.role_path' if variable is set to null<br>    desc                 = optional(string)           # Defaults to 'var.role_desc' if variable is set to null<br>    trust_policy_file    = string                     # Path to file of trust/assume policy. Will be templated if vars are passed.<br>    trust_policy_vars    = optional(map(string), {})  # Policy template variables {key = val, ...}<br>    permissions_boundary = optional(string)           # ARN to a policy used as permissions boundary (or null/empty)<br>    policies             = optional(list(string), []) # List of names of policies (must be defined in var.policies)<br>    policy_arns          = optional(list(string), []) # List of existing policy ARN's<br>    inline_policies = optional(list(object({<br>      name = string                    # Name of the inline policy<br>      file = string                    # Path to json or json.tmpl file of policy<br>      vars = optional(map(string), {}) # Policy template variables {key = val, ...}<br>    })), [])<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policies"></a> [policies](#output\_policies) | Created customer managed IAM policies |
| <a name="output_roles"></a> [roles](#output\_roles) | Created roles |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
