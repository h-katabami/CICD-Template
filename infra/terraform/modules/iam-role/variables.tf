variable "role_name" {
  type        = string
  description = "IAM role name"
}

variable "path" {
  type        = string
  description = "IAM role path"
  default     = "/"
}

variable "managed_policy_arns" {
  type        = list(string)
  description = "Managed policies to attach"
  default     = []
}

variable "inline_policy_json" {
  type        = string
  description = "Optional inline policy JSON"
  default     = null
}

variable "inline_policy_file" {
  type        = string
  description = "Optional local file path to inline policy JSON"
  default     = null
}
