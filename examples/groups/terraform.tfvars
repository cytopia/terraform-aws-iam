policies = [
  {
    name = "billing-ro"
    path = "/assume/"
    desc = "Provides read-only access to billing"
    file = "data/billing-ro.json"
    vars = {}
  },
]

groups = [
  {
    name            = "GRP-CUSTOM-POLICY"
    path            = null
    policies        = ["billing-ro"]
    policy_arns     = []
    inline_policies = []
  },
  {
    name            = "GRP-POLICY-ARN"
    path            = null
    policies        = []
    policy_arns     = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    inline_policies = []
  },
  {
    name        = "GRP-INLINE-POLICY"
    path        = null
    policies    = []
    policy_arns = []
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
    name     = "GRP-MULTIPLE-POLICIES"
    path     = null
    policies = []
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
]
