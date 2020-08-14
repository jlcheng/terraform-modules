variable "cluster_id" {
  description = "The id of the cluster, e.g., my_first_cluster"
}

variable "env" {
  description = "environment: one of e, p, or s"
}

variable "tags" {
  description = "Additional tags to add to resources"
  default     = {}
}

locals {
  tags = merge({
    ManagedBy = "Terraform"
    env       = var.env
  }, var.tags)
}
