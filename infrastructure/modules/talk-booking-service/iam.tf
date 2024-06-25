resource "aws_iam_role" "ecs-host-role" {
  name = "${var.environment_name}-ecs-host-role"
  assume_role_policy = jsonencode(
    {
      Version = "2008-10-17",
      Statement = [
        {
          Action = "sts:AssumeRole",
          Principal = {
            Service = [
              "ecs.amazonaws.com",
              "ecs-tasks.amazonaws.com",
              "ec2.amazonaws.com"
            ]
          },
          Effect = "Allow"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "ecs-instance-role-policy" {
  name = "${var.environment_name}-ecs-instance-role-policy"
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "ecs:*",
            "elasticloadbalancing:*",
            "ecr:*",
            "cloudwatch:*",
            "logs:*"
          ],
          Resource = "*"
        }
      ]
    }
  )
  role = aws_iam_role.ecs-host-role.id
}

resource "aws_iam_role" "ecs-task-execution-role" {
  name = "${var.environment_name}-app-execution-role"

  assume_role_policy = jsonencode(
    {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Action": "sts:AssumeRole",
         "Principal": {
           "Service": "ecs-tasks.amazonaws.com"
         },
         "Effect": "Allow",
         "Sid": ""
       }
     ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role" {
  role = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
