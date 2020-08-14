resource "aws_iam_role" "task_execution_role" {
  name = "ecs-cluster-${var.cluster_id}-role"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole",
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          },
          Effect = "Allow",
          Sid    = ""
        }
      ]
  })
  tags = merge({
    Name = "task_execution_role_${var.cluster_id}_${var.env}"
  }, local.tags)
}

resource "aws_iam_role_policy_attachment" "task-execution-role-policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
