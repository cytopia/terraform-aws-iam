policies = [
  {
    name = "billing-ro"
    path = "/assume/"
    desc = "Provides read-only access to billing"
    file = "data/billing-ro.json"
  },
]

roles = [
  {
    name              = "ROLE-CUSTOM-POLICY"
    trust_policy_file = "data/trust-policy-file.json"
    policies          = ["billing-ro"]
  },
  {
    name              = "ROLE-POLICY-ARN"
    trust_policy_file = "data/trust-policy-template.json.tmpl"
    trust_policy_vars = {
      aws_account_id = "123456789012"
    }
    policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  },
  {
    name                 = "ROLE-INLINE-POLICY"
    instance_profile     = null
    path                 = null
    desc                 = null
    trust_policy_file    = "data/trust-policy-file.json"
    trust_policy_vars    = null
    permissions_boundary = null
    policies             = []
    policy_arns          = []
    inline_policies = [
      {
        name = "rds-authenticate"
        file = "data/rds-authenticate.json.tmpl"
        vars = {
          aws_account_id = "1234567890"
        }
      }
    ]
  },
  {
    name              = "ROLE-MULTIPLE-POLICIES"
    trust_policy_file = "data/trust-policy-file.json"
    policy_arns = [
      "arn:aws:iam::aws:policy/PowerUserAccess",
      "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    ]
    inline_policies = [
      {
        name = "rds-authenticate"
        file = "data/rds-authenticate.json.tmpl"
        vars = {
          aws_account_id = "1234567890"
        }
      },
      {
        name = "billing-ro"
        file = "data/billing-ro.json"
      }
    ]
  },
  {
    name                 = "ROLE-PERMISSION-BOUNDARY"
    trust_policy_file    = "data/trust-policy-file.json"
    permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"
    policy_arns          = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  },
  {
    name              = "ROLE-ATTACHED-TO-AN-INSTANCE-PROFILE"
    instance_profile  = "MY-INSTANCE-PROFILE-1"
    trust_policy_file = "data/trust-policy-file.json"
    policy_arns       = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  },
]
