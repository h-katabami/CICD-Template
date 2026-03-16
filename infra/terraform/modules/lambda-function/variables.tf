variable "function_name" {
  type        = string
  description = "Lambda function name"
}

variable "description" {
  type        = string
  description = "Lambda description"
}

variable "role_arn" {
  type        = string
  description = "Execution role ARN"
}

variable "handler" {
  type        = string
  description = "Lambda handler"
}

variable "runtime" {
  type        = string
  description = "Lambda runtime"
}

variable "timeout" {
  type        = number
  description = "Lambda timeout"
}

variable "memory_size" {
  type        = number
  description = "Lambda memory size"
}

variable "ephemeral_storage_size" {
  type        = number
  description = "Lambda ephemeral storage size (MB)"
  default     = null
}

variable "architectures" {
  type        = list(string)
  description = "Lambda architectures"
}

variable "zip_path" {
  type        = string
  description = "Zip archive path"
}

variable "statement_id" {
  type        = string
  description = "Permission statement id"
}

variable "source_lambda_arn" {
  type        = string
  description = "Source Lambda ARN"
  default     = null
}

variable "create_permission" {
  type        = bool
  description = "Create invoke permission"
  default     = false
}

variable "environment_variables" {
  type        = map(string)
  description = "Lambda environment variables"
  default     = {}
}
