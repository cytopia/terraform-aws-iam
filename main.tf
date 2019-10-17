# ------------------------------------------------------------------------------------------------
# Create Roles
# ------------------------------------------------------------------------------------------------

resource "aws_iam_role" "roles" {
  count = "${length(var.roles)}"

  name        = "${lookup(var.roles[count.index], "name")}"
  path        = "${lookup(var.roles[count.index], "path", "") == "" ? var.role_path : lookup(var.roles[count.index], "path")}"
  description = "${lookup(var.roles[count.index], "desc", "") == "" ? var.role_desc : lookup(var.roles[count.index], "desc")}"

  # This policy defines who/what is allowed to use the current role
  assume_role_policy = "${file(lookup(var.roles[count.index], "trust_policy_file"))}"

  # Allow session for X seconds
  max_session_duration  = "${var.max_session_duration}"
  force_detach_policies = "${var.force_detach_policies}"

  tags = "${merge(
    map("Name", lookup(var.roles[count.index], "name")),
    var.tags
  )}"
}

# ------------------------------------------------------------------------------------------------
# Create Policies for above Roles
# ------------------------------------------------------------------------------------------------

resource "aws_iam_policy" "policies" {
  count = "${length(var.roles)}"

  name        = "${lookup(var.roles[count.index], "policy_name")}"
  path        = "${lookup(var.roles[count.index], "policy_path", "") == "" ? var.policy_path : lookup(var.roles[count.index], "policy_path")}"
  description = "${lookup(var.roles[count.index], "policy_desc", "") == "" ? var.policy_desc : lookup(var.roles[count.index], "policy_desc")}"

  # This defines what permissions our role will be given
  policy = "${file(lookup(var.roles[count.index], "policy_file"))}"
}

# ------------------------------------------------------------------------------------------------
# Attach Policies to Role
# ------------------------------------------------------------------------------------------------
# IMPORTANT: https://www.terraform.io/docs/providers/aws/r/iam_policy_attachment.html

# Exclusive attachment of roles
resource "aws_iam_policy_attachment" "exclusive_policy_attachment" {
  count = "${var.exclusive_policy_attachment ? length(var.roles) : 0}"

  name       = "${lookup(var.roles[count.index], "policy_name")}"
  roles      = ["${element(aws_iam_role.roles.*.name, count.index)}"]
  policy_arn = "${aws_iam_policy.policies.*.arn[count.index]}"
}

# Additive adding of roles
resource "aws_iam_role_policy_attachment" "imperative_policy_attachment" {
  count = "${var.exclusive_policy_attachment ? 0 : length(var.roles)}"

  role       = "${element(aws_iam_role.roles.*.name, count.index)}"
  policy_arn = "${aws_iam_policy.policies.*.arn[count.index]}"
}
