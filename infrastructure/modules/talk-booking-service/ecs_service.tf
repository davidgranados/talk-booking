resource "aws_ecs_task_definition" "app" {
  family                = "${var.environment_name}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn            = aws_iam_role.ecs-host-role.arn

  container_definitions = jsonencode(
    [
        {
          name = "talk-booking-app",
          image = "busybox:latest",
          cpu = 512,
          command = [
            "gunicorn",
            "--bind",
            "0.0.0.0:${var.container_port}",
            "web_app.main:app",
            "-k",
            "uvicorn.workers.UvicornWorker"
          ],
          memory: 1024,
          essential = true,
          environment = [
            {name = "APP_ENVIRONMENT", value = var.app_environment},
            {name = "AWS_DEFAULT_REGION", value = var.region}
          ],
          portMappings = [
            {
              "containerPort": var.container_port
            }
          ],
          logConfiguration = {
            "logDriver": "awslogs",
            "options": {
              "awslogs-group": aws_cloudwatch_log_group.talk-booking-log-group.name,
              "awslogs-region": var.region,
              "awslogs-stream-prefix": aws_cloudwatch_log_stream.talk-booking-log-stream.name
            }
          }
        }
    ]
  )
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_ecs_service" "talk-booking-service" {
  name            = var.environment_name
  cluster         = aws_ecs_cluster.talk-booking-cluster.name
  task_definition = aws_ecs_task_definition.app.family
  desired_count   = var.app_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
   security_groups  = [var.ecs_security_group_id]
   subnets          = [var.private_subnet_1_id, var.private_subnet_2_id]
   assign_public_ip = false
 }

  load_balancer {
    target_group_arn = aws_alb_target_group.default-target-group.arn
    container_name   = "talk-booking-app"
    container_port   = var.container_port
  }
  depends_on = [aws_alb_listener.ecs-alb-http-listener]

  lifecycle {
    ignore_changes = [task_definition]
  }
}
