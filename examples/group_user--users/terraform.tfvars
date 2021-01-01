policies = [
  {
    name = "billing-ro"
    path = "/assume/"
    desc = "Provides read-only access to billing"
    file = "data/billing-ro.json"
    vars = {}
  },
]

users = [
  {
    name                 = "USER-CUSTOM-POLICY"
    path                 = null
    groups               = []
    access_keys          = []
    permissions_boundary = null
    policies             = ["billing-ro"]
    policy_arns          = []
    inline_policies      = []
  },
  {
    name                 = "USER-POLICY-ARN"
    path                 = null
    groups               = []
    access_keys          = []
    permissions_boundary = null
    policies             = []
    policy_arns          = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    inline_policies      = []
  },
  {
    name                 = "USER-INLINE-POLICY"
    path                 = null
    groups               = []
    access_keys          = []
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
    name                 = "USER-MULTIPLE-POLICIES"
    path                 = null
    groups               = []
    access_keys          = []
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
    name                 = "USER-PERMISSION-BOUNDARY"
    path                 = null
    groups               = []
    access_keys          = []
    permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"
    policies             = []
    policy_arns          = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    inline_policies      = []
  },
  {
    name   = "USER-ACCESS-KEY-1"
    path   = null
    groups = []
    access_keys = [
      {
        name    = "key-1"
        pgp_key = ""
        status  = "Active"
      },
    ]
    permissions_boundary = null
    policies             = []
    policy_arns          = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    inline_policies      = []
  },
  {
    name   = "USER-ACCESS-KEY-2"
    path   = null
    groups = []
    access_keys = [
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
    permissions_boundary = null
    policies             = []
    policy_arns          = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    inline_policies      = []
  },
]
