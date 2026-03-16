variable "name" {
  type        = string
  description = "SSM parameter name"
}

variable "description" {
  type        = string
  description = "SSM parameter description"
  default     = null
}

variable "type" {
  type        = string
  description = "SSM parameter type"
  default     = "String"
}

variable "value" {
  type        = string
  description = "SSM parameter value"
}

variable "overwrite" {
  type        = bool
  description = "Overwrite SSM parameter value when changed"
  default     = true
}

variable "tier" {
  type        = string
  description = "SSM parameter tier"
  default     = "Standard"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
