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
  #        "name" = "<policy-name>"
  #        "path" = "<policy-path>"
  #        "desc" = "<policy-desc>"
  #        "file" = "<policy-file>"
  #     }
  #   },
  # ]

  _role_policies = flatten([
    for i, role in var.roles : [
      for j, policy in lookup(var.roles[i], "policies", {}) : {
        "${var.roles[i]["name"]}:${var.roles[i]["policies"][j]}" = local.policies[var.roles[i]["policies"][j]]
      }
    ]
  ])
  # The fix to bring it into the format stated at the top of this file
  role_policies = {
    for i, v in local._role_policies :
    keys(local._role_policies[i])[0] => local._role_policies[i][keys(local._role_policies[i])[0]]
  }
}


# -------------------------------------------------------------------------------------------------
# Inline Policy transformations
# -------------------------------------------------------------------------------------------------

locals {
  # This local extracts inline_policies from var.roles and combines the found policies
  # with the role names as shown below:
  #
  #   inline_policies = [
  #     {
  #       "<role-name>:<policy-name>" = {
  #         "name" = ""
  #         "file" = ""
  #       }
  #     },
  #     {
  #       "<role-name>:<policy-name>" = {
  #         "name" = ""
  #         "file" = ""
  #       }
  #     },
  #   ]

  _inline_policies = flatten([
    for i, role in var.roles : [
      for j, inline_policy in lookup(var.roles[i], "inline_policies", {}) : {
        "${var.roles[i]["name"]}:${var.roles[i]["inline_policies"][j]["name"]}" = inline_policy
      }
    ]
  ])
  # The fix to bring it into the format stated at the top of this file
  inline_policies = {
    for i, v in local._inline_policies :
    keys(local._inline_policies[i])[0] => local._inline_policies[i][keys(local._inline_policies[i])[0]]
  }
}


# -------------------------------------------------------------------------------------------------
# Policy Arn transformations
# -------------------------------------------------------------------------------------------------

locals {
  # This local extracts policy_arns from var.roles and combines the found policies
  # with the role names as shown below:
  #
  #   policy_arns = [
  #     {
  #       "<role-name>:<policy-arn>" = "<policy-arn">
  #     },
  #     {
  #       "<role-name>:<policy-arn>" = "<policy-arn">
  #     },
  #   ]

  _policy_arns = flatten([
    for i, role in var.roles : [
      for j, policy_arn in lookup(var.roles[i], "policy_arns", {}) : {
        "${var.roles[i]["name"]}:${var.roles[i]["policy_arns"][j]}" = policy_arn
      }
    ]
  ])
  # The fix to bring it into the format stated at the top of this file
  policy_arns = {
    for i, v in local._policy_arns :
    keys(local._policy_arns[i])[0] => local._policy_arns[i][keys(local._policy_arns[i])[0]]
  }
}
