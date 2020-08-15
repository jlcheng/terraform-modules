variable "svcid" {
  description = "An id for the service. Limited to alphanumerics and dash. No spaces."
}

variable "env" {
  description = "Environment: one of p or s"
}

variable "iam_task_policy" {
  description = "An IAM policy document"
}

variable "td_image" {
  description = "A FQDN for docker image, e.g., 0000.dkr.ecr.us-west-2.amazonaws.com/helloworld:0.0.1"
}

variable "td_cpu" {
  description = "Optional: CPU attribute of task definition; 256"
  default     = 256
}

variable "td_memory" {
  description = "Optional: Memory attribute of task definition; 512"
  default     = 512
}

variable "td_env" {
  description = "Optional: A list of {name='key', value='bar'} objects"
  default     = []
}

variable "td_containerPort" {
  description = "The portMappings.containerPort attribute of task definition"
}

variable "td_awslogs_region" {
  description = "The logConfiguration.options.awslogs-group attribute of task definition"
}

variable "desired_count" {
  description = "Optional: The number of tasks to run. When set to 1, ECS will try to spin up a healthy instance before killing the old one"
  default     = 1
}

variable "execution_role_arn" {
  description = "ARN of the execution role"
}

variable "vpc_id" {
  description = "VPC to deploy relevant security group into"
}

variable "sg_ingress_from_port" {
  description = "Optional: The from_port for the security group, if different than td_containerPort"
  default     = ""
}

variable "sg_ingress_to_port" {
  description = "Optional: The to_port for the security group, if different than td_containerPort"
  default     = ""
}

variable "health_check_path" {
  description = "Optional: Path for health checks, defaults to /"
  default     = "/"
}

variable "lb_listener_arn" {
  description = "ARN of an https ALB listener, e.g., aws_alb_listener.ecs_hello_world_https_listener.arn"
}

variable "lb_listener_domain" {
  description = "FQDN of the API, e.g., scribblesdev.api.jchengdev.org"
}

variable "ecs_cluster_arn" {
  description = "ID of the ECS cluster to deploy to"
}

variable "private_subnet_ids" {
  description = "The private subnets for ECS tasks"
}

variable "tags" {
  description = "Optional: Additional tags to add to resources"
  default     = {}
}

locals {
  tags = merge({
    ManagedBy = "Terraform"
    env       = var.env
  }, var.tags)
}
