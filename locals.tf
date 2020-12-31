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
# Group/User/Role Policy transformations
# -------------------------------------------------------------------------------------------------

locals {
  # [group_policies]
  # This local combines var.groups and var.policies and creates its own list as shown below:
  #
  # group_policies = [
  #   {
  #     "<group-name>:<policy-name>" = {
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
  gp = flatten([
    for group in var.groups : [
      for policy in group["policies"] : {
        group_name  = group.name
        policy_name = policy
        policy      = local.policies[policy]
      }
    ]
  ])
  group_policies = { for obj in local.gp : "${obj.group_name}:${obj.policy_name}" => obj.policy }

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
}


# -------------------------------------------------------------------------------------------------
# Role/User Inline Policy transformations
# -------------------------------------------------------------------------------------------------

locals {
  # [group_inline_policies]
  # This local extracts inline_group_policies from var.groups and combines the found policies
  # with the group names as shown below:
  #
  # group_inline_policies = [
  #   {
  #     "<group-name>:<policy-name>" = {
  #       name = "<policy-name>"
  #       file = "<policy-file>"
  #       vars = {
  #         key = "val",
  #       }
  #     }
  #   },
  #   {
  #     "<group-name>:<policy-name>" = {
  #       name = "<policy-name>"
  #       file = "<policy-file>"
  #       vars = {
  #         key = "val",
  #       }
  #     }
  #   },
  # ]
  gip = flatten([
    for group in var.groups : [
      for inline_policy in group["inline_policies"] : {
        group_name  = group.name
        policy_name = inline_policy["name"]
        policy      = inline_policy
      }
    ]
  ])
  group_inline_policies = { for obj in local.gip : "${obj.group_name}:${obj.policy_name}" => obj.policy }

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
}


# -------------------------------------------------------------------------------------------------
# Group/User/Role Policy Arn transformations
# -------------------------------------------------------------------------------------------------

locals {
  # [group_policy_arns]
  # This local extracts policy_arns from var.groups and combines the found policies
  # with the group names as shown below:
  #
  # group_policy_arns = [
  #   {
  #     "<group-name>:<policy-arn>" = "<policy-arn>"
  #   },
  #   {
  #     "<group-name>:<policy-arn>" = "<policy-arn>"
  #   },
  # ]
  gpa = flatten([
    for group in var.groups : [
      for policy_arn in group["policy_arns"] : {
        group_name = group.name
        policy_arn = policy_arn
        policy     = policy_arn
      }
    ]
  ])
  group_policy_arns = { for obj in local.gpa : "${obj.group_name}:${obj.policy_arn}" => obj.policy }

  # [user_policy_arns]
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

  # [role_policy_arns]
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
}


# -------------------------------------------------------------------------------------------------
# User Access key transformations
# -------------------------------------------------------------------------------------------------

locals {
  # [user_access_keys]
  # This local transforms users into a useable user_access_keys list
  #
  # user_access_keys = [
  #   {
  #     "<user-name>:<key-name>" = {
  #       user_name  = "<user-name>"      # required to distinguish between one of the two keys
  #       key_name   = "<key-name>"       # required to distinguish between one of the two keys
  #       pgp_key    = "<pgp-key>"        # or empty
  #       status     = "Active|Inactive"  # or empty
  #     },
  #   },
  #   {
  #     "<user-name>:<key-name>" = {
  #       user_name  = "<user-name>"      # required to distinguish between one of the two keys
  #       key_name   = "<key-name>"       # required to distinguish between one of the two keys
  #       pgp_key    = "<pgp-key>"        # or empty
  #       status     = "Active|Inactive"  # or empty
  #     },
  #   },
  # ]
  uak = flatten([
    for user in var.users : [
      for user_access_key in user["access_keys"] : {
        user_name = user.name
        key_name  = user_access_key.name
        pgp_key   = user_access_key.pgp_key
        status    = user_access_key.status
      }
    ]
  ])
  user_access_keys = { for obj in local.uak : "${obj.user_name}:${obj.key_name}" => obj }
}
