policies = [
  {
    name = "billing-ro"
    path = "/assume/"
    desc = "Provides read-only access to billing"
    file = "data/billing-ro.json"
  },
]

groups = [
  {
    name     = "GRP-CUSTOM-POLICY"
    policies = ["billing-ro"]
  },
  {
    name        = "GRP-POLICY-ARN"
    policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  },
  {
    name = "GRP-INLINE-POLICY"
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
    name = "GRP-MULTIPLE-POLICIES"
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
]
