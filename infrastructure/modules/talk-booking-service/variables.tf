variable "region" {
  description = "The AWS region to create resources in."
}
variable "vpc_id" {
  description = "ID od VPC"
  type = string
}

variable "environment_name" {
  description = "Name of app environment. Must be unique."
  type = string
}

variable "ecs_security_group_id" {
  description = "ID of ECS security group"
  type = string
}
variable "load_balancer_security_group_id" {
  description = "ID of ALB security group"
  type = string
}

variable "log_retention_in_days" {
  description = "Log retention in days"
  type = number
}

variable "public_subnet_1_id" {
  description = "Id of first public subnet"
  type = string
}

variable "public_subnet_2_id" {
  description = "Id of second public subnet"
  type = string
}

variable "private_subnet_1_id" {
  description = "Id of first private subnet"
  type = string
}

variable "private_subnet_2_id" {
  description = "Id of second private subnet"
  type = string
}

variable "app_count" {
  description = "Desired number of running apps"
  type = number
}

variable "container_port" {
  description = "App container port"
  type = number
  default = 5000
}

variable "app_environment" {
  description = "Application environment"
  type = string
}
