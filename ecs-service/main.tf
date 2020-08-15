# ----------------------------------------------------------------------
# Log group
# ----------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "service" {
  name              = "jc/ecs/${var.svcid}-${var.env}"
  retention_in_days = 90

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role" "task_role" {
  name = "task-${var.svcid}-${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
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
  tags = local.tags
}

resource "aws_iam_policy" "task_role" {
  name   = "task-${var.svcid}-${var.env}"
  policy = var.iam_task_policy
}

resource "aws_iam_role_policy_attachment" "task_role" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_role.arn
}


# ----------------------------------------------------------------------
# Task definition
# ----------------------------------------------------------------------
resource "aws_ecs_task_definition" "service" {
  family = "service-${var.svcid}-${var.env}"
  container_definitions = jsonencode([
    {
      name        = "${var.svcid}-${var.env}"
      image       = var.td_image
      cpu         = var.td_cpu
      memory      = var.td_memory
      essential   = true
      environment = var.td_env
      portMappings = [
        {
          containerPort = var.td_containerPort
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "jc/ecs/${var.svcid}-${var.env}"
          awslogs-region        = var.td_awslogs_region
          awslogs-stream-prefix = "${var.svcid}-${var.env}"
        }
      }
    }
  ])
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.td_cpu
  memory                   = var.td_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = aws_iam_role.task_role.arn


  volume {
    name = "service-storage"
  }

  tags = local.tags
}

# ----------------------------------------------------------------------
# Security group
# ----------------------------------------------------------------------

resource "aws_security_group" "service_sg" {
  name        = "ecs-sg-${var.svcid}-${var.env}"
  description = "Security group for ${var.svcid}-${var.env}"
  vpc_id      = var.vpc_id
  ingress {
    description = "${var.svcid}-${var.env} ingress"
    protocol    = "tcp"
    from_port   = coalesce(var.td_containerPort, var.sg_ingress_from_port)
    to_port     = coalesce(var.td_containerPort, var.sg_ingress_to_port)
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}

# ----------------------------------------------------------------------
# A target group for the ECS > hello_world:8000
# ----------------------------------------------------------------------
resource "aws_alb_target_group" "service_tg" {
  name        = "ecs-tg-${var.svcid}-${var.env}"
  port        = var.td_containerPort
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

  tags = local.tags
}


// Associate the target group with LB
resource "aws_lb_listener_rule" "service_rule" {
  listener_arn = var.lb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.service_tg.arn
  }

  condition {
    host_header {
      values = [var.lb_listener_domain]
    }
  }
}


resource "aws_ecs_service" "service" {
  name            = "service-${var.svcid}-${var.env}"
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.service_sg.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  # Associate the task definition with the ALB target group
  load_balancer {
    target_group_arn = aws_alb_target_group.service_tg.arn
    container_name   = "${var.svcid}-${var.env}"
    container_port   = var.td_containerPort
  }

  # Requires the user to opt-in via. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-modifying-longer-id-settings.html
  enable_ecs_managed_tags = true
  # LATEST platform version as of 2020-07-04
  platform_version = "1.4.0"

  tags = local.tags
}

