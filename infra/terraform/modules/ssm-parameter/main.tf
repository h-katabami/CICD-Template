resource "aws_ssm_parameter" "this" {
  name        = var.name
  description = var.description
  type        = var.type
  value       = var.value
  overwrite   = var.overwrite
  tier        = var.tier
  tags        = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}
