data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

locals {
  inline_policy_raw = var.inline_policy_json != null ? var.inline_policy_json : (
    var.inline_policy_file != null ? file(var.inline_policy_file) : null
  )

  inline_policy_clean = local.inline_policy_raw == null ? null : replace(local.inline_policy_raw, "\ufeff", "")

  inline_policy = local.inline_policy_clean == null ? null : jsonencode(jsondecode(local.inline_policy_clean))
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  path               = var.path
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  count = local.inline_policy == null ? 0 : 1

  name   = "${var.role_name}-inline"
  role   = aws_iam_role.this.id
  policy = local.inline_policy
}
