variable "env" {
  type        = string
  description = "The environment, e.g., 'p' or 's'"
}

variable "sub_domain_name" {
  type        = string
  description = "The primary 'domain_name' for the SSL certificate, e.g., api.example.com"
}

variable "sub_domain_alternative_names" {
  type        = list(string)
  description = "A list of subject alternative names, e.g., ['*.api.example.com', 'auth.api.example.com', 'stg.api.example.com']"
}

variable "create_before_destroy" {
  type        = bool
  description = "See aws_acm_certificate"
}

variable "zone_id" {
  type        = string
  description = "The zone_id that the sub_domain_name belongs to"
}

variable "tags" {
  type        = map(any)
  description = "Optional: Additional tags to add to resources"
  default     = {}
}

locals {
  tags = merge({
    ManagedBy = "Terraform"
    env       = var.env
  }, var.tags)
}

