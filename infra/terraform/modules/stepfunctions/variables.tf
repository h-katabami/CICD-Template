variable "name" {
  type        = string
  description = "Step Functions state machine name"
}

variable "worker_lambda_arn" {
  type        = string
  description = "Worker Lambda function ARN"
}

variable "trigger_bucket_name" {
  type        = string
  description = "S3 bucket name to trigger workflow"
}

variable "trigger_key_prefix" {
  type        = string
  description = "S3 object key prefix filter"
  default     = null
}

variable "trigger_key_suffix" {
  type        = string
  description = "S3 object key suffix filter"
  default     = null
}

variable "schedule_expression" {
  type        = string
  description = "EventBridge schedule expression (e.g. cron(...) or rate(...))"
}

variable "trigger_enabled" {
  type        = bool
  description = "Enable or disable EventBridge trigger rule"
  default     = false
}

variable "wait_seconds" {
  type        = number
  description = "Polling wait seconds for import status"
  default     = 10
}

variable "delete_wait_seconds" {
  type        = number
  description = "Wait seconds before deleting old table"
  default     = 86400
}

variable "tags" {
  type        = map(string)
  description = "Tags for created resources"
  default     = {}
}
