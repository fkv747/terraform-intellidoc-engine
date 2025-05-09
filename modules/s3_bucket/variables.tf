variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
}

variable "enable_versioning" {
  type        = bool
  default     = true
  description = "Enable versioning on the bucket."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the S3 bucket."
}
