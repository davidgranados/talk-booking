resource "aws_ecs_cluster" "talk-booking-cluster" {
  name = var.environment_name
}
