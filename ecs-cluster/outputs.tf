output "ecs_cluster_arn" {
  description = "The ARN of the generated cluster"
  value       = aws_ecs_cluster.self.arn
}
