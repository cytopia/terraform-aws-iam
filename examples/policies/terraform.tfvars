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
