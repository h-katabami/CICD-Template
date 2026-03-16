variable "bucket_name" {
  type        = string
  description = "S3 bucket name"
}

variable "force_destroy" {
  type        = bool
  description = "Delete all objects (including versions) when destroying the bucket"
  default     = true
}

variable "versioning_enabled" {
  type        = bool
  description = "Enable S3 versioning"
  default     = false
}

variable "block_public_acls" {
  type        = bool
  description = "Block public ACLs"
  default     = true
}

variable "block_public_policy" {
  type        = bool
  description = "Block public bucket policies"
  default     = true
}

variable "ignore_public_acls" {
  type        = bool
  description = "Ignore public ACLs"
  default     = true
}

variable "restrict_public_buckets" {
  type        = bool
  description = "Restrict public buckets"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}

variable "eventbridge_enabled" {
  type        = bool
  description = "Enable EventBridge notifications for this bucket"
  default     = false
}

variable "lambda_notifications" {
  type = list(object({
    enabled              = optional(bool, true)
    statement_id         = string
    lambda_function_name = string
    lambda_function_arn  = string
    events               = list(string)
    filter_prefix        = optional(string)
    filter_suffix        = optional(string)
  }))
  description = "Lambda notifications for S3 object events"
  default     = []
}

variable "cors_rules" {
  type = list(object({
    allowed_headers = optional(list(string), ["*"])
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number)
  }))
  description = "S3 CORS rules"
  default     = []
}

variable "lifecycle_rules" {
  type = list(object({
    id              = string
    prefix          = string
    expiration_days = number
  }))
  description = "S3 lifecycle expiration rules"
  default     = []
}
