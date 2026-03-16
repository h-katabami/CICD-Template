data "aws_iam_policy_document" "stepfunctions_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "stepfunctions" {
  name               = "${var.name}-stepfunctions-role"
  assume_role_policy = data.aws_iam_policy_document.stepfunctions_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "stepfunctions" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      var.worker_lambda_arn
    ]
  }
}

resource "aws_iam_role_policy" "stepfunctions" {
  name   = "${var.name}-stepfunctions-inline"
  role   = aws_iam_role.stepfunctions.id
  policy = data.aws_iam_policy_document.stepfunctions.json
}

resource "aws_sfn_state_machine" "this" {
  name     = var.name
  role_arn = aws_iam_role.stepfunctions.arn

  definition = jsonencode({
    Comment = "S3 to DynamoDB import workflow"
    StartAt = "StartS3ToDynamoDB"
    States = {
      StartS3ToDynamoDB = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.worker_lambda_arn
          Payload = {
            action       = "START_IMPORT"
            "bucket.$"  = "$.bucket"
            "key.$"     = "$.key"
            "key_prefix.$" = "$.key_prefix"
            "key_suffix.$" = "$.key_suffix"
          }
        }
        ResultPath = "$.start"
        Next       = "StartImportCompleted"
      }
      StartImportCompleted = {
        Type = "Choice"
        Choices = [
          {
            Variable     = "$.start.Payload.status"
            StringEquals = "SKIPPED"
            Next         = "ImportSucceeded"
          }
        ]
        Default = "WaitImport"
      }
      WaitImport = {
        Type    = "Wait"
        Seconds = var.wait_seconds
        Next    = "CheckImport"
      }
      CheckImport = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.worker_lambda_arn
          Payload = {
            action              = "CHECK_IMPORT"
            "import_arn.$"     = "$.start.Payload.import_arn"
            "new_table_name.$" = "$.start.Payload.new_table_name"
            "bucket.$"         = "$.start.Payload.bucket"
            "key.$"            = "$.start.Payload.key"
          }
        }
        ResultPath = "$.check"
        Next       = "ImportCompleted"
      }
      ImportCompleted = {
        Type = "Choice"
        Choices = [
          {
            Variable     = "$.check.Payload.status"
            StringEquals = "COMPLETED"
            Next         = "SwitchTableName"
          },
          {
            Variable     = "$.check.Payload.status"
            StringEquals = "IN_PROGRESS"
            Next         = "WaitImport"
          }
        ]
        Default = "RollbackImport"
      }
      RollbackImport = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.worker_lambda_arn
          Payload = {
            action             = "ROLLBACK"
            "new_table_name.$" = "$.check.Payload.new_table_name"
          }
        }
        ResultPath = "$.rollback"
        Next       = "ImportFailed"
      }
      SwitchTableName = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.worker_lambda_arn
          Payload = {
            action             = "SWITCH_TABLE"
            "new_table_name.$" = "$.check.Payload.new_table_name"
          }
        }
        ResultPath = "$.switch"
        Next       = "WaitBeforeCleanupOldTable"
      }
      WaitBeforeCleanupOldTable = {
        Type    = "Wait"
        Seconds = var.delete_wait_seconds
        Next    = "CleanupOldTable"
      }
      CleanupOldTable = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.worker_lambda_arn
          Payload = {
            action             = "CLEANUP_OLD_TABLE"
            "new_table_name.$" = "$.switch.Payload.new_table_name"
            "old_table_name.$" = "$.switch.Payload.old_table_name"
          }
        }
        ResultPath = "$.cleanup"
        Next       = "ImportSucceeded"
      }
      ImportFailed = {
        Type  = "Fail"
        Error = "S3ToDynamoDBImportFailed"
      }
      ImportSucceeded = {
        Type = "Succeed"
      }
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "trigger" {
  name                = "${var.name}-schedule-trigger"
  schedule_expression = var.schedule_expression
  is_enabled          = var.trigger_enabled
  tags = var.tags

  lifecycle {
    ignore_changes = [is_enabled]
  }
}

data "aws_iam_policy_document" "eventbridge_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eventbridge" {
  name               = "${var.name}-eventbridge-role"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "eventbridge" {
  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      aws_sfn_state_machine.this.arn
    ]
  }
}

resource "aws_iam_role_policy" "eventbridge" {
  name   = "${var.name}-eventbridge-inline"
  role   = aws_iam_role.eventbridge.id
  policy = data.aws_iam_policy_document.eventbridge.json
}

resource "aws_cloudwatch_event_target" "trigger" {
  rule      = aws_cloudwatch_event_rule.trigger.name
  target_id = "${var.name}-state-machine"
  arn       = aws_sfn_state_machine.this.arn
  role_arn  = aws_iam_role.eventbridge.arn

  input = jsonencode({
    bucket     = var.trigger_bucket_name
    key        = ""
    key_prefix = var.trigger_key_prefix
    key_suffix = var.trigger_key_suffix
  })
}
