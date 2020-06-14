resource "aws_vpc" "vpc" {
  cidr_block           = lookup(var.settings, "${terraform.workspace}.vpc.cidr_block")
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name        = "${var.project}-${terraform.workspace}"
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${terraform.workspace}"
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

resource "aws_route" "route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${terraform.workspace}"
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table" "route_table-datastore" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${terraform.workspace}"
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

resource "aws_main_route_table_association" "main_route_table_association" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "route_table_association-a" {
  subnet_id      = aws_subnet.datastore-a.id
  route_table_id = aws_route_table.route_table-datastore.id
}

resource "aws_route_table_association" "route_table_association-c" {
  subnet_id      = aws_subnet.datastore-c.id
  route_table_id = aws_route_table.route_table-datastore.id
}

resource "aws_subnet" "frontend-a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet("${aws_vpc.vpc.cidr_block}", 8, 0)
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-${terraform.workspace}-frontend-a"
    Environment = terraform.workspace
    Subnet      = "frontend"
    ManagedBy   = "Terraform"
  }
}

resource "aws_subnet" "frontend-c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet("${aws_vpc.vpc.cidr_block}", 8, 1)
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-${terraform.workspace}-frontend-c"
    Environment = terraform.workspace
    Subnet      = "frontend"
    ManagedBy   = "Terraform"
  }
}

resource "aws_subnet" "application-a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet("${aws_vpc.vpc.cidr_block}", 8, 2)
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-${terraform.workspace}-application-a"
    Environment = terraform.workspace
    Subnet      = "application"
    ManagedBy   = "Terraform"
  }
}

resource "aws_subnet" "application-c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet("${aws_vpc.vpc.cidr_block}", 8, 3)
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-${terraform.workspace}-application-c"
    Environment = terraform.workspace
    Subnet      = "application"
    ManagedBy   = "Terraform"
  }
}

resource "aws_subnet" "datastore-a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet("${aws_vpc.vpc.cidr_block}", 8, 4)
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project}-${terraform.workspace}-datastore-a"
    Environment = terraform.workspace
    Subnet      = "datastore"
    ManagedBy   = "Terraform"
  }
}

resource "aws_subnet" "datastore-c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet("${aws_vpc.vpc.cidr_block}", 8, 5)
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project}-${terraform.workspace}-datastore-c"
    Environment = terraform.workspace
    Subnet      = "datastore"
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "common" {
  name        = "${var.project}-${terraform.workspace}-common"
  description = "Security Group for ${var.project}-${terraform.workspace}"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${terraform.workspace}-common"
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group_rule" "common-ingress" {
  security_group_id = aws_security_group.common.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
}

resource "aws_security_group_rule" "common-egress" {
  security_group_id = aws_security_group.common.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
