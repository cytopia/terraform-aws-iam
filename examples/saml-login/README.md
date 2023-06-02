# SAML Login

Use Microsoft Azure, ADFS or any other compatible SAML provider to log in into AWS.

## Overview

This example adds SAML as an identity provider to log into AWS into an initially assumed *login role* and be able to assume roles in various other AWS accounts from there.

The initial assumed *login role* (after login) does not have any permissions assigned except one to assume further into other roles. Then the other assumed roles explicitly state that they can only be assumed by one of the initially assumed *login roles*.


## Best-practice

It is a good idea to separate *logins* and *permissions* by using different AWS accounts.

1. Login Account: Users (from an identity provider) can login and assume a *login role* with no permissions (except assume). Both roles and identity provider are defined in this account.
2. Other accounts: These accounts define roles that can be assumed from the *login role* and will have actual permissions.

Keep in mind that you might still want to have access to the *login account* and should therefore also create *assume roles* to ensure *login* and *assume* roles are completely separated (even in the same account).

## Example

### `terraform.tfvars`
```hcl
# Adding AzureAD as a login provider to AWS so
# that you can login via AzureAD into the AWS account
# and assume an initial role
providers_saml = [
  {
    name = "AzureAD"
    file = "data/provider-saml.xml"
  }
]

# Adding a policy which allows to assume other resources
policies = [
  {
    name = "sts-assume-policy"
    path = "/login/assume/"
    desc = "Allow to assume other resources"
    file = "data/policy-sts-assume.json"
    vars = {}
  },
]

# Adding two roles
# LOGIN-ADMIN can be assumed after AzureAD login
# ASSUME-ADMIN can be assumed from LOGIN-ADMIN
roles = [
  {
    name                 = "LOGIN-ADMIN"
    path                 = "/login/saml/"
    desc                 = "Initial login role"
    trust_policy_file    = "data/trust-policy-saml.json"
    permissions_boundary = null
    policies             = ["sts-assume-policy"]
    inline_policies      = []
    policy_arns          = []
  },
  {
    name                 = "ASSUME-ADMIN"
    path                 = "/assume/"
    desc                 = "Admin role"
    trust_policy_file    = "data/trust-policy-LOGIN-ADMIN.json"
    permissions_boundary = null
    policies             = []
    inline_policies      = []
    policy_arns          = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  },
]
```


### `data/provider-saml.xml`

The SAML provider file will be provided by the SAML service. The following is just a simple extract:
```xml
<EntityDescriptor ID="_aaaaaa-11aa-22bb-33dd-asdsds" entityID="http://azure.example.com/services/trust" xmlns="urn:oasis:names:tc:SAML:2.0:metadata">
...
</EntityDescriptor>
```

### `data/trust-policy-saml.json`

The trust policy file allows the `LOGIN-ADMIN` role to be assumed by the login provider `AzureAD`.

> Roles must be *assumed*. The AWS resource which is allowed to assume a specific role has to be defined on a per role base via its `trust_policy_file`.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRoleWithSAML",
      "Principal": {
        "Federated": "arn:aws:iam::1234567890:saml-provider/AzureAD"
      },
      "Condition": {
        "StringEquals": {
          "SAML:aud": "https://signin.aws.amazon.com/saml"
        }
      }
    }
  ]
}
```

### `data/policy-sts-assume.json`

The `sts-assume-policy` attached to the `LOGIN-ADMIN` role allows it to further assume into other resources.

> Policies define certain permissions and can be attached to an AWS resource, which will then be allowed those permissions.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "*"
    }
  ]
}
```

### `data/trust-policy-LOGIN-ADMIN.json`

The trust policy file allows the `ASSUME-ADMIN` role to be assumed by the `LOGIN-ADMIN` role:

> Roles must be *assumed*. The AWS resource which is allowed to assume a specific role has to be defined on a per role base via its `trust_policy_file`.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": [
          "arn:aws:iam::1234567890:role/login/saml/LOGIN-ADMIN"
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

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_alias | Assign the account alias for the AWS Account. Unmanaged by default. Resource will be created if the string is non-empty. | `string` | `""` | no |
| account\_pass\_policy | Manages Password Policy for the AWS Account. Unmanaged by default. Resource will be created if 'manage' is set to true. | <pre>object({<br>    manage                         = optional(bool, false) # Set to true, to manage the AWS account password policy<br>    allow_users_to_change_password = optional(bool)        # Allow users to change their own password?<br>    hard_expiry                    = optional(bool)        # Users are prevented from setting a new password after their password has expired?<br>    max_password_age               = optional(number)      # Number of days that an user password is valid<br>    minimum_password_length        = optional(number)      # Minimum length to require for user passwords<br>    password_reuse_prevention      = optional(number)      # The number of previous passwords that users are prevented from reusing<br>    require_lowercase_characters   = optional(bool)        # Require lowercase characters for user passwords?<br>    require_numbers                = optional(bool)        # Require numbers for user passwords?<br>    require_symbols                = optional(bool)        # Require symbols for user passwords?<br>    require_uppercase_characters   = optional(bool)        # Require uppercase characters for user passwords?<br>  })</pre> | `{}` | no |
| providers\_saml | A list of dictionaries defining saml providers. | <pre>list(object({<br>    name = string # The name of the provider to create<br>    file = string # Path to XML generated by identity provider that supports SAML 2.0<br>  }))</pre> | `[]` | no |
| providers\_oidc | A list of dictionaries defining openid connect providers. | <pre>list(object({<br>    url             = string       # URL of the identity provider. Corresponds to the iss claim<br>    client_id_list  = list(string) # List of client IDs (also known as audiences)<br>    thumbprint_list = list(string) # List of server certificate thumbprints.<br>  }))</pre> | `[]` | no |
| policies | A list of dictionaries defining all policies. | <pre>list(object({<br>    name = string                    # Name of the policy<br>    path = optional(string)          # Defaults to 'var.policy_path' if variable is set to null<br>    desc = optional(string)          # Defaults to 'var.policy_desc' if variable is set to null<br>    file = string                    # Path to json or json.tmpl file of policy<br>    vars = optional(map(string), {}) # Policy template variables {key = val, ...}<br>  }))</pre> | `[]` | no |
| groups | A list of dictionaries defining all groups. | <pre>list(object({<br>    name        = string                     # Name of the group<br>    path        = optional(string)           # Defaults to 'var.group_path' if variable is set to null<br>    policies    = optional(list(string), []) # List of names of policies (must be defined in var.policies)<br>    policy_arns = optional(list(string), []) # List of existing policy ARN's<br>    inline_policies = optional(list(object({<br>      name = string                    # Name of the inline policy<br>      file = string                    # Path to json or json.tmpl file of policy<br>      vars = optional(map(string), {}) # Policy template variables {key = val, ...}<br>    })), [])<br>  }))</pre> | `[]` | no |
| users | A list of dictionaries defining all users. | <pre>list(object({<br>    name   = string                     # Name of the user<br>    path   = optional(string)           # Defaults to 'var.user_path' if variable is set to null<br>    groups = optional(list(string), []) # List of group names to add this user to<br>    access_keys = optional(list(object({<br>      name    = string                     # IaC identifier for first or second IAM access key (not used on AWS)<br>      pgp_key = optional(string)           # Leave empty for non or provide a b64-enc pubkey or keybase username<br>      status  = optional(string, "Active") # 'Active' or 'Inactive'<br>    })), [])<br>    permissions_boundary = optional(string)           # ARN to a policy used as permissions boundary (or null/empty)<br>    policies             = optional(list(string), []) # List of names of policies (must be defined in var.policies)<br>    policy_arns          = optional(list(string), []) # List of existing policy ARN's<br>    inline_policies = optional(list(object({<br>      name = string                    # Name of the inline policy<br>      file = string                    # Path to json or json.tmpl file of policy<br>      vars = optional(map(string), {}) # Policy template variables {key = val, ...}<br>    })), [])<br>  }))</pre> | `[]` | no |
| roles | A list of dictionaries defining all roles. | <pre>list(object({<br>    name                 = string                     # Name of the role<br>    instance_profile     = optional(string)           # Name of the instance profile<br>    path                 = optional(string)           # Defaults to 'var.role_path' if variable is set to null<br>    desc                 = optional(string)           # Defaults to 'var.role_desc' if variable is set to null<br>    trust_policy_file    = string                     # Path to file of trust/assume policy. Will be templated if vars are passed.<br>    trust_policy_vars    = optional(map(string), {})  # Policy template variables {key = val, ...}<br>    permissions_boundary = optional(string)           # ARN to a policy used as permissions boundary (or null/empty)<br>    policies             = optional(list(string), []) # List of names of policies (must be defined in var.policies)<br>    policy_arns          = optional(list(string), []) # List of existing policy ARN's<br>    inline_policies = optional(list(object({<br>      name = string                    # Name of the inline policy<br>      file = string                    # Path to json or json.tmpl file of policy<br>      vars = optional(map(string), {}) # Policy template variables {key = val, ...}<br>    })), [])<br>  }))</pre> | `[]` | no |
| policy\_path | The default path under which to create the policy if not specified in the policies list. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure. | `string` | `"/"` | no |
| policy\_desc | The default description of the policy. | `string` | `"Managed by Terraform"` | no |
| group\_path | The path under which to create the group. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure. | `string` | `"/"` | no |
| user\_path | The path under which to create the user. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure. | `string` | `"/"` | no |
| role\_path | The path under which to create the role. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure. | `string` | `"/"` | no |
| role\_desc | The description of the role. | `string` | `"Managed by Terraform"` | no |
| role\_max\_session\_duration | The maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours specified in seconds. | `number` | `3600` | no |
| role\_force\_detach\_policies | Specifies to force detaching any policies the role has before destroying it. | `bool` | `true` | no |
| tags | Key-value mapping of tags for the IAM role or user. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| policies | Created customer managed IAM policies |
| roles | Created roles |
| providers\_saml | Created SAML providers. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
