# -------------------------------------------------------------------------------------------------
# Policy transformations
# -------------------------------------------------------------------------------------------------

locals {
  # Transforn from:
  #
  # policies = [
  #   {
  #     name = ""
  #     path = ""
  #     desc = ""
  #     file = ""
  #   },
  #   {
  #     name = ""
  #     path = ""
  #     desc = ""
  #     file = ""
  #   },
  # }
  #
  # Into the following format:
  #
  # policies = {
  #   "<policy-name>" = {
  #     name = ""
  #     path = ""
  #     desc = ""
  #     file = ""
  #   }
  #   "<policy-name>" = {
  #     name = ""
  #     path = ""
  #     desc = ""
  #     file = ""
  #   }
  # }
  policies = { for i, v in var.policies : var.policies[i]["name"] => v }
}


# -------------------------------------------------------------------------------------------------
# Role Policy transformations
# -------------------------------------------------------------------------------------------------

locals {

  # This local combines var.roles and var.policies and creates its own list as shown below:
  #
  # role_policies = [
  #   {
  #     "<role-name>:<policy-name>" = {
  #       "name" = "<policy-name>"
  #       "path" = "<policy-path>"
  #       "desc" = "<policy-desc>"
  #       "file" = "<policy-file>"
  #       "vars" = {key = val}
  #     }
  #   },
  # ]
  rp = flatten([
    for role in var.roles : [
      for policy in role["policies"] : {
        role_name   = role.name
        policy_name = policy
        policy      = local.policies[policy]
      }
    ]
  ])

  role_policies = { for obj in local.rp : "${obj.role_name}:${obj.policy_name}" => obj.policy }
}


# -------------------------------------------------------------------------------------------------
# Inline Policy transformations
# -------------------------------------------------------------------------------------------------

locals {
  # This local extracts inline_policies from var.roles and combines the found policies
  # with the role names as shown below:
  #
  # inline_policies = [
  #   {
  #     "<role-name>:<policy-name>" = {
  #       "name" = ""
  #       "file" = ""
  #       "vars" = {key = val}
  #     }
  #   },
  #   {
  #     "<role-name>:<policy-name>" = {
  #       "name" = ""
  #       "file" = ""
  #       "vars" = ""
  #     }
  #   },
  # ]
  ip = flatten([
    for role in var.roles : [
      for inline_policy in role["inline_policies"] : {
        role_name   = role.name
        policy_name = inline_policy["name"]
        policy      = inline_policy
      }
    ]
  ])

  inline_policies = { for obj in local.ip : "${obj.role_name}:${obj.policy_name}" => obj.policy }
}


# -------------------------------------------------------------------------------------------------
# Policy Arn transformations
# -------------------------------------------------------------------------------------------------

locals {
  # This local extracts policy_arns from var.roles and combines the found policies
  # with the role names as shown below:
  #
  # policy_arns = [
  #   {
  #     "<role-name>:<policy-arn>" = "<policy-arn">
  #   },
  #   {
  #     "<role-name>:<policy-arn>" = "<policy-arn">
  #   },
  # ]
  pa = flatten([
    for role in var.roles : [
      for policy_arn in role["policy_arns"] : {
        role_name  = role.name
        policy_arn = policy_arn
        policy     = policy_arn
      }
    ]
  ])

  policy_arns = { for obj in local.pa : "${obj.role_name}:${obj.policy_arn}" => obj.policy }
}
