policies = [
  {
    name = "billing-ro"
    path = "/assume/"
    desc = "Provides read-only access to billing"
    file = "data/billing-ro.json"
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
    policies = ["rds-authenticate", "billing-ro"]
    policy_arns = [
      "arn:aws:iam::aws:policy/AdministratorAccess",
    ]
  },
  {
    name     = "GRP-DEVELOPER"
    policies = ["rds-authenticate"]
    policy_arns = [
      "arn:aws:iam::aws:policy/PowerUserAccess",
    ]
  }
]

users = [
  {
    name   = "john"
    path   = "/human/"
    groups = ["GRP-ADMIN"]
    access_keys = [
      {
        name = "key-1"
      },
    ]
  },
  {
    name   = "jane"
    path   = "/human/"
    groups = ["GRP-DEVELOPER"]
    access_keys = [
      {
        name   = "key-1"
        status = "Inactive"
      },
      {
        name = "key-2"
      },
    ]
  },
]
