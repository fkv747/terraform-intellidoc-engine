variable "opensearch_url" {
  description = "Full OpenSearch domain endpoint (no trailing slash)"
  type        = string
}

variable "opensearch_index" {
  description = "Index name to search"
  type        = string
}

variable "opensearch_domain_arn" {
  description = "ARN of OpenSearch domain"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
