policies = [
  {
    name = "billing-ro"
    path = "/assume/"
    desc = "Provides read-only access to billing"
    file = "data/billing-ro.json"
    vars = {}
  },
]

roles = [
  {
    name                 = "ROLE-CUSTOM-POLICY"
    instance_profile     = null
    path                 = null
    desc                 = null
    trust_policy_file    = "data/trust-policy-file.json"
    trust_policy_vars    = null
    permissions_boundary = null
    policies             = ["billing-ro"]
    policy_arns          = []
    inline_policies      = []
  },
  {
    name              = "ROLE-POLICY-ARN"
    instance_profile  = null
    path              = null
    desc              = null
    trust_policy_file = "data/trust-policy-template.json.tmpl"
    trust_policy_vars = {
      aws_account_id = "123456789012"
    }
    permissions_boundary = null
    policies             = []
    policy_arns          = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    inline_policies      = []
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
    name                 = "ROLE-MULTIPLE-POLICIES"
    path                 = null
    desc                 = null
    trust_policy_file    = "data/trust-policy-file.json"
    trust_policy_vars    = null
    permissions_boundary = null
    policies             = []
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
        vars = {}
      }
    ]
  },
  {
    name                 = "ROLE-PERMISSION-BOUNDARY"
    path                 = null
    desc                 = null
    trust_policy_file    = "data/trust-policy-file.json"
    trust_policy_vars    = null
    permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"
    policies             = []
    policy_arns          = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    inline_policies      = []
  },
  {
    name                 = "ROLE-ATTACHED-TO-AN-INSTANCE-PROFILE"
    instance_profile     = "MY-INSTANCE-PROFILE-1"
    path                 = null
    desc                 = null
    trust_policy_file    = "data/trust-policy-file.json"
    trust_policy_vars    = null
    permissions_boundary = null
    policies             = []
    policy_arns          = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    inline_policies      = []
  },
]
