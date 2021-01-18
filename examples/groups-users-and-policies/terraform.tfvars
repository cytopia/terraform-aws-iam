policies = [
  {
    name = "billing-ro"
    path = "/assume/"
    desc = "Provides read-only access to billing"
    file = "data/billing-ro.json"
    vars = {}
  },
  {
    name = "rds-authenticate"
    path = "/assume/"
    desc = "Allow user to authenticate to RDS via IAM"
    file = "data/rds-authenticate.json.tmpl"
    vars = {
      aws_account_id = "1234567890",
    }
  },
]

groups = [
  {
    name     = "GRP-ADMIN"
    path     = null
    policies = ["rds-authenticate", "billing-ro"]
    policy_arns = [
      "arn:aws:iam::aws:policy/AdministratorAccess",
    ]
    inline_policies = []
  },
  {
    name     = "GRP-DEVELOPER"
    path     = null
    policies = ["rds-authenticate"]
    policy_arns = [
      "arn:aws:iam::aws:policy/PowerUserAccess",
    ]
    inline_policies = []
  }
]

users = [
  {
    name   = "john"
    path   = "/human/"
    groups = ["GRP-ADMIN"]
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
    policy_arns          = []
  },
  {
    name   = "jane"
    path   = "/human/"
    groups = ["GRP-DEVELOPER"]
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
    inline_policies      = []
    policy_arns          = []
  },
]
