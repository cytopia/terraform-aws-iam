# Terraform module: AWS IAM Roles

[![Build Status](https://travis-ci.org/cytopia/terraform-aws-iam-roles.svg?branch=master)](https://travis-ci.org/cytopia/terraform-aws-iam-roles)
[![Tag](https://img.shields.io/github/tag/cytopia/terraform-aws-iam-roles.svg)](https://github.com/cytopia/terraform-aws-iam-roles/releases)
[![Terraform](https://img.shields.io/badge/Terraform--registry-aws--iam--roles-brightgreen.svg)](https://registry.terraform.io/modules/cytopia/iam-roles/aws/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This Terraform module can create an arbitrary number of IAM roles with policies and trusted
entities defined as JSON files.

**Note:** Policy attachments can be done decleratively (exclusive) or imperatively (shared).


## Usage

### Login roles via SAML

```hcl
module "iam_roles" {
  source = "github.com/cytopia/terraform-aws-iam-roles?ref=v0.1.0"

  # List of roles to manage
  roles = [
    {
      name = "LOGIN-ADMIN"
      trust_policy_file = "logins/admin-assume.json"
      policy_name = "login-admin"
      policy_path = "/federation/"
      policy_file = "logins/admin-policy.json"
    }
  ]
```

**`logins/admin-assume.json`**

Defines the trusted entity (Authentication)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789:saml-provider/MyADFS"
      },
      "Action": "sts:AssumeRoleWithSAML",
      "Condition": {
        "StringEquals": {
          "SAML:aud": "https://signin.aws.amazon.com/saml"
        }
      }
    }
  ]
}
```

**`logins/admin-policy.json`**

Defines the permissions (Authorization)
```json
{
   "Version": "2012-10-17",
   "Statement": [{
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "*"
   }]
}
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| roles | A list of dictionaries defining all roles. | list | n/a | yes |
| role\_path | The path under which to create the role. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division_abc/subdivision_xyz/product_1234/engineering/ to match your company's organizational structure. | string | `"/"` | no |
| role\_desc | The description of the role. | string | `"Managed by Terraform"` | no |
| max\_session\_duration | The maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours. | string | `"3600"` | no |
| force\_detach\_policies | Specifies to force detaching any policies the role has before destroying it. | string | `"true"` | no |
| tags | Key-value mapping of tags for the IAM role. | map | `<map>` | no |
| policy\_path | The default path under which to create the policy if not specified in the policies list. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division_abc/subdivision_xyz/product_1234/engineering/ to match your company's organizational structure. | string | `"/"` | no |
| policy\_desc | The default description of the policy. | string | `"Managed by Terraform"` | no |
| exclusive\_policy\_attachment | If true, the aws_iam_policy_attachment resource creates exclusive attachments of IAM policies. Across the entire AWS account, all of the users/roles/groups to which a single policy is attached must be declared by a single aws_iam_policy_attachment resource. This means that even any users/roles/groups that have the attached policy via any other mechanism (including other Terraform resources) will have that attached policy revoked by this resource. | string | `"true"` | no |


## Outputs

| Name | Description |
|------|-------------|
| roles | The defined roles list |
| role\_ids | The stable and unique string identifying the role. |
| role\_arns | The Amazon Resource Name (ARN) specifying the role. |
| role\_names | The name of the role. |
| role\_paths | The path to the role. |
| role\_session\_durations | The maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours. |
| role\_force\_detach\_policies | Specifies to force detaching any policies the role has before destroying it. |
| role\_policies | A list of the policy definitions. |
| role\_assume\_policies | A list of the policy definitions. |
| policy\_arns | A list of ARN assigned by AWS to the policies. |
| policy\_ids | A list of unique IDs of the policies. |
| policy\_names | A list of names of the policies. |
| policy\_paths | A list of paths of the policies. |
| exclusive\_policy\_attachment\_ids | A list of unique IDs of exclusive policy attachments. |
| exclusive\_policy\_attachment\_names | A list of names of exclusive policy attachments. |
| exclusive\_policy\_attachment\_policy\_arns | A list of ARNs of exclusive policy attachments. |
| exclusive\_policy\_attachment\_role\_names | A list of role names of exclusive policy attachments. |
| imperative\_policy\_attachment\_ids | A list of unique IDs of shared policy attachments. |
| imperative\_policy\_attachment\_names | A list of names of shared policy attachments. |
| imperative\_policy\_attachment\_policy\_arns | A list of ARNs of shared policy attachments. |
| imperative\_policy\_attachment\_role\_names | A list of role names of shared policy attachments. |


## Authors

Module managed by [cytopia](https://github.com/cytopia).


## License

[MIT License](LICENSE)

Copyright (c) 2018 [cytopia](https://github.com/cytopia)
