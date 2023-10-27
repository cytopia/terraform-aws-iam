# Access key rotation

This is not a terraform example, but rather a howto on how to rotate AWS access keys with this module.


## Workflow

Let's assume we have the following user:

`terraform.tfvars`
```hcl
users = [
  {
    name        = "ci-deploy"
    path        = null
    groups      = []
    access_keys = [
      {
        name    = "key-1"
        pgp_key = ""
        status  = "Active"
      },
    ]
    permissions_boundary = null
    policies             = []
    inline_policies      = []
    policy_arns = [
      "arn:aws:iam::aws:policy/AdministratorAccess",
    ]
  }
]
```

Before rotating the access key of the `ci-deploy` user, we're going to create another access key first:

`terraform.tfvars`
```hcl
users = [
  {
    name        = "ci-deploy"
    path        = null
    groups      = []
    access_keys = [
      {
        name    = "key-1"
        pgp_key = ""
        status  = "Active"
      },
      {
        name    = "key-2"
        pgp_key = ""
        status  = "Active"
      },
    ]
    permissions_boundary = null
    policies             = []
    inline_policies      = []
    policy_arns = [
      "arn:aws:iam::aws:policy/AdministratorAccess",
    ]
  }
]
```
We can then safely replace the access key and secrets at various locations. Once we have replaced them everywhere we can remove the old access key:

`terraform.tfvars`
```hcl
users = [
  {
    name        = "ci-deploy"
    path        = null
    groups      = []
    access_keys = [
      {
        name    = "key-2"
        pgp_key = ""
        status  = "Active"
      },
    ]
    permissions_boundary = null
    policies             = []
    inline_policies      = []
    policy_arns = [
      "arn:aws:iam::aws:policy/AdministratorAccess",
    ]
  }
]
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
