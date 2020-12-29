# -------------------------------------------------------------------------------------------------
# Policy transformations
# -------------------------------------------------------------------------------------------------

locals {
  # Transforn from:
  #
  # policies = [
  #   {
  #     name = "<policy-name>"
  #     path = "<policy-path>"
  #     desc = "<policy-desc>"
  #     file = "<policy-file>"
  #     vars = {
  #       key = "val",
  #     }
  #   },
  #   {
  #     name = "<policy-name>"
  #     path = "<policy-path>"
  #     desc = "<policy-desc>"
  #     file = "<policy-file>"
  #     vars = {
  #       key = "val",
  #     }
  #   },
  # }
  #
  # Into the following format:
  #
  # policies = {
  #   "<policy-name>" = {
  #     name = "<policy-name>"
  #     path = "<policy-path>"
  #     desc = "<policy-desc>"
  #     file = "<policy-file>"
  #     vars = {
  #       key = "val",
  #     }
  #   }
  #   "<policy-name>" = {
  #     name = "<policy-name>"
  #     path = "<policy-path>"
  #     desc = "<policy-desc>"
  #     file = "<policy-file>"
  #     vars = {
  #       key = "val",
  #     }
  #   }
  # }
  policies = { for i, v in var.policies : var.policies[i]["name"] => v }
}


# -------------------------------------------------------------------------------------------------
# Role/User Policy transformations
# -------------------------------------------------------------------------------------------------

locals {
  # [role_policies]
  # This local combines var.roles and var.policies and creates its own list as shown below:
  #
  # role_policies = [
  #   {
  #     "<role-name>:<policy-name>" = {
  #       name = "<policy-name>"
  #       path = "<policy-path>"
  #       desc = "<policy-desc>"
  #       file = "<policy-file>"
  #       vars = {
  #         key = "val",
  #       }
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

  # [user_policies]
  # This local combines var.users and var.policies and creates its own list as shown below:
  #
  # user_policies = [
  #   {
  #     "<user-name>:<policy-name>" = {
  #       name = "<policy-name>"
  #       path = "<policy-path>"
  #       desc = "<policy-desc>"
  #       file = "<policy-file>"
  #       vars = {
  #         key = "val",
  #       }
  #     }
  #   },
  # ]
  up = flatten([
    for user in var.users : [
      for policy in user["policies"] : {
        user_name   = user.name
        policy_name = policy
        policy      = local.policies[policy]
      }
    ]
  ])
  user_policies = { for obj in local.up : "${obj.user_name}:${obj.policy_name}" => obj.policy }
}


# -------------------------------------------------------------------------------------------------
# Role/User Inline Policy transformations
# -------------------------------------------------------------------------------------------------

locals {
  # [role_inline_policies]
  # This local extracts inline_role_policies from var.roles and combines the found policies
  # with the role names as shown below:
  #
  # role_inline_policies = [
  #   {
  #     "<role-name>:<policy-name>" = {
  #       name = "<policy-name>"
  #       file = "<policy-file>"
  #       vars = {
  #         key = "val",
  #       }
  #     }
  #   },
  #   {
  #     "<role-name>:<policy-name>" = {
  #       name = "<policy-name>"
  #       file = "<policy-file>"
  #       vars = {
  #         key = "val",
  #       }
  #     }
  #   },
  # ]
  rip = flatten([
    for role in var.roles : [
      for inline_policy in role["inline_policies"] : {
        role_name   = role.name
        policy_name = inline_policy["name"]
        policy      = inline_policy
      }
    ]
  ])
  role_inline_policies = { for obj in local.rip : "${obj.role_name}:${obj.policy_name}" => obj.policy }

  # [user_inline_policies]
  # This local extracts inline_user_policies from var.users and combines the found policies
  # with the user names as shown below:
  #
  # user_inline_policies = [
  #   {
  #     "<user-name>:<policy-name>" = {
  #       name = "<policy-name>"
  #       file = "<policy-file>"
  #       vars = {
  #         key = "val",
  #       }
  #     }
  #   },
  #   {
  #     "<user-name>:<policy-name>" = {
  #       name = "<policy-name>"
  #       file = "<policy-file>"
  #       vars = {
  #         key = "val",
  #       }
  #     }
  #   },
  # ]
  uip = flatten([
    for user in var.users : [
      for inline_policy in user["inline_policies"] : {
        user_name   = user.name
        policy_name = inline_policy["name"]
        policy      = inline_policy
      }
    ]
  ])
  user_inline_policies = { for obj in local.uip : "${obj.user_name}:${obj.policy_name}" => obj.policy }
}


# -------------------------------------------------------------------------------------------------
# Role/User Policy Arn transformations
# -------------------------------------------------------------------------------------------------

locals {
  # This local extracts policy_arns from var.roles and combines the found policies
  # with the role names as shown below:
  #
  # role_policy_arns = [
  #   {
  #     "<role-name>:<policy-arn>" = "<policy-arn>"
  #   },
  #   {
  #     "<role-name>:<policy-arn>" = "<policy-arn>"
  #   },
  # ]
  rpa = flatten([
    for role in var.roles : [
      for policy_arn in role["policy_arns"] : {
        role_name  = role.name
        policy_arn = policy_arn
        policy     = policy_arn
      }
    ]
  ])
  role_policy_arns = { for obj in local.rpa : "${obj.role_name}:${obj.policy_arn}" => obj.policy }

  # This local extracts policy_arns from var.users and combines the found policies
  # with the user names as shown below:
  #
  # user_policy_arns = [
  #   {
  #     "<user-name>:<policy-arn>" = "<policy-arn>"
  #   },
  #   {
  #     "<user-name>:<policy-arn>" = "<policy-arn>"
  #   },
  # ]
  upa = flatten([
    for user in var.users : [
      for policy_arn in user["policy_arns"] : {
        user_name  = user.name
        policy_arn = policy_arn
        policy     = policy_arn
      }
    ]
  ])
  user_policy_arns = { for obj in local.upa : "${obj.user_name}:${obj.policy_arn}" => obj.policy }
}
