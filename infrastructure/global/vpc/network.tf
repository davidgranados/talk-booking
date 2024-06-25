# Production VPC
resource "aws_vpc" "talk-booking-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
}

# Public subnets
resource "aws_subnet" "public-subnet-1" {
    vpc_id = aws_vpc.talk-booking-vpc.id
    cidr_block = var.public_subnet_1_cidr
    availability_zone = var.availability_zones[0]
}
resource "aws_subnet" "public-subnet-2" {
    vpc_id = aws_vpc.talk-booking-vpc.id
    cidr_block = var.public_subnet_2_cidr
    availability_zone = var.availability_zones[1]
}

# Private subnets
resource "aws_subnet" "private-subnet-1" {
    vpc_id = aws_vpc.talk-booking-vpc.id
    cidr_block = var.private_subnet_1_cidr
    availability_zone = var.availability_zones[0]
}
resource "aws_subnet" "private-subnet-2" {
    vpc_id = aws_vpc.talk-booking-vpc.id
    cidr_block = var.private_subnet_2_cidr
    availability_zone = var.availability_zones[1]
}

# Route tables for the subnets
resource "aws_route_table" "public-route-table" {
    vpc_id = aws_vpc.talk-booking-vpc.id
}
resource "aws_route_table" "private-route-table" {
    vpc_id = aws_vpc.talk-booking-vpc.id
}

# Route table associations
resource "aws_route_table_association" "public-subnet-1-association" {
    subnet_id = aws_subnet.public-subnet-1.id
    route_table_id = aws_route_table.public-route-table.id
}
resource "aws_route_table_association" "public-subnet-2-association" {
    subnet_id = aws_subnet.public-subnet-2.id
    route_table_id = aws_route_table.public-route-table.id
}
resource "aws_route_table_association" "private-subnet-1-association" {
    subnet_id = aws_subnet.private-subnet-1.id
    route_table_id = aws_route_table.private-route-table.id
}
resource "aws_route_table_association" "private-subnet-2-association" {
    subnet_id = aws_subnet.private-subnet-2.id
    route_table_id = aws_route_table.private-route-table.id
}

# Elastic IP
resource "aws_eip" "elastic-ip-for-nat-gw" {
    domain = "vpc"
    associate_with_private_ip = "10.0.0.5"
    depends_on = [ aws_internet_gateway.production-igw ]
}

# NAT Gateway
resource "aws_nat_gateway" "nat-gw" {
    allocation_id = aws_eip.elastic-ip-for-nat-gw.id
    subnet_id = aws_subnet.public-subnet-1.id
    depends_on = [ aws_eip.elastic-ip-for-nat-gw ]
}
resource "aws_route" "nat-gw-route" {
    route_table_id = aws_route_table.private-route-table.id
    nat_gateway_id = aws_nat_gateway.nat-gw.id
    destination_cidr_block = "0.0.0.0/0"
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "production-igw" {
    vpc_id = aws_vpc.talk-booking-vpc.id
}

# Route the public subnet traffic through the Internet Gateway
resource "aws_route" "public-internet-igw-route" {
    route_table_id = aws_route_table.public-route-table.id
    gateway_id = aws_internet_gateway.production-igw.id
    destination_cidr_block = "0.0.0.0/0"
}

# VPC endpoints
resource "aws_vpc_endpoint" "s3" {
    vpc_id = aws_vpc.talk-booking-vpc.id
    service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
    route_table_id = aws_route_table.private-route-table.id
    vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "s3-private" {
    route_table_id = aws_route_table.private-route-table.id
    vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint" "dkr" {
    vpc_id = aws_vpc.talk-booking-vpc.id
    service_name = "com.amazonaws.${var.region}.ecr.dkr"
    vpc_endpoint_type = "Interface"
    security_group_ids = [
        aws_security_group.vpc-endpoints.id
    ]
    private_dns_enabled = true
    subnet_ids = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
}

resource "aws_vpc_endpoint" "ecr" {
    vpc_id = aws_vpc.talk-booking-vpc.id
    service_name = "com.amazonaws.${var.region}.ecr.api"
    vpc_endpoint_type = "Interface"
    security_group_ids = [
        aws_security_group.vpc-endpoints.id
    ]
    private_dns_enabled = true
    subnet_ids = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
}

resource "aws_security_group" "vpc-endpoints" {
    vpc_id = aws_vpc.talk-booking-vpc.id
    name = "vpc-endpoints"
    description = "Security group to control VPC endpoints inbound/outbound rules"

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        security_groups = [aws_security_group.ecs.id]
    }

    tags = {
        Name = "vpc-endpoints"
    }
}
