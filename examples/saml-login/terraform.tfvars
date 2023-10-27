# Adding AzureAD as a login provider to AWS so
# that you can login via AzureAD into the AWS account
# and assume an initial role
providers_saml = [
  {
    name = "AzureAD"
    file = "data/provider-saml.xml"
  }
]

# Adding a policy which allows to assume other resources
policies = [
  {
    name = "sts-assume-policy"
    path = "/login/assume/"
    desc = "Allow to assume other resources"
    file = "data/policy-sts-assume.json"
  },
]

# Adding two roles
# LOGIN-ADMIN can be assumed after AzureAD login
# ASSUME-ADMIN can be assumed from LOGIN-ADMIN
roles = [
  {
    name              = "LOGIN-ADMIN"
    path              = "/login/saml/"
    desc              = "Initial login role"
    trust_policy_file = "data/trust-policy-saml.json"
    policies          = ["sts-assume-policy"]
  },
  {
    name                 = "ASSUME-ADMIN"
    path                 = "/assume/"
    desc                 = "Admin role"
    trust_policy_file    = "data/trust-policy-LOGIN-ADMIN.json"
    permissions_boundary = null
    policies             = []
    inline_policies      = []
    policy_arns          = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  },
]
