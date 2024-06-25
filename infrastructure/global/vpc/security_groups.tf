# ALB Security Group (Traffic Internet -> ALB)
resource "aws_security_group" "load-balancer" {
    vpc_id = aws_vpc.talk-booking-vpc.id
    name = "load_balancer_security_group"
    description = "Control access to the ALB"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# ECS Security group (traffic ALB -> ECS)
resource "aws_security_group" "ecs" {
    vpc_id = aws_vpc.talk-booking-vpc.id
    name = "ecs_security_group"
    description = "Control inbound access from the ALB only"
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = [aws_security_group.load-balancer.id]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
