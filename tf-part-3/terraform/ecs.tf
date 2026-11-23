resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

# IAM Role for ECS to pull images from ECR
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Flask Task Definition (Smallest Fargate size: 0.25 vCPU / 0.5 GB)
resource "aws_ecs_task_definition" "flask" {
  family                   = "${var.project_name}-flask-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "flask-container"
    image     = "${aws_ecr_repository.flask.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = var.flask_port
      hostPort      = var.flask_port
    }]
  }])
}

# Express Task Definition (Smallest Fargate size: 0.25 vCPU / 0.5 GB)
resource "aws_ecs_task_definition" "express" {
  family                   = "${var.project_name}-express-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "express-container"
    image     = "${aws_ecr_repository.express.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = var.express_port
      hostPort      = var.express_port
    }]
  }])
}

# Flask ECS Service
resource "aws_ecs_service" "flask" {
  name            = "${var.project_name}-flask-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.flask.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.flask.arn
    container_name   = "flask-container"
    container_port   = var.flask_port
  }

  depends_on = [aws_lb_listener.http]
}

# Express ECS Service
resource "aws_ecs_service" "express" {
  name            = "${var.project_name}-express-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.express.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.express.arn
    container_name   = "express-container"
    container_port   = var.express_port
  }

  depends_on = [aws_lb_listener.http]
}
