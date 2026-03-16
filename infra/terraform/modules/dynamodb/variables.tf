variable "table_name" {
  type        = string
  description = "DynamoDB table name"
}

variable "hash_key" {
  type        = string
  description = "DynamoDB hash key"
}

variable "range_key" {
  type        = string
  description = "DynamoDB range key"
  default     = null
}

variable "attributes" {
  type = list(object({
    name = string
    type = string
  }))
  description = "DynamoDB attributes"
}

variable "global_secondary_indexes" {
  type = list(object({
    name            = string
    hash_key        = string
    range_key       = optional(string)
    projection_type = optional(string, "ALL")
  }))
  description = "DynamoDB global secondary indexes"
  default     = []
}

variable "deletion_protection_enabled" {
  type        = bool
  description = "Enable deletion protection"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
