#------------------------------------------------------------------------------
# AWS ECS Cluster
#------------------------------------------------------------------------------
resource "aws_ecs_cluster" "self" {
  name               = "${var.cluster_id}-${var.env}"
  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }

  # Disabled because of cost
  # Metrics collected by Container Insights are charged as custom metrics.
  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = merge({
    Name        = "ecs_cluster_${var.cluster_id}_${var.env}"
    Description = "ECS Cluster ${var.cluster_id} ${var.env}"
  }, local.tags)
}

