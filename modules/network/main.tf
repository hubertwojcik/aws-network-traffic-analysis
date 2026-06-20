data "aws_availability_zones" "available" {
    state = "available"   
}

locals {
    az = data.aws_availability_zones.available.names[0]

    name_prefix = var.project_name
}

resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = merge(var.common_tags, {
        Name = "${local.name_prefix}-vpc"
    })
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id

    tags = merge(var.common_tags, {
        Name = "${local.name_prefix}-igw"
    })
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.this.id
    cidr_block = var.public_subnet_cidr
    availability_zone = local.az
    map_public_ip_on_launch = true

    tags = merge(var.common_tags, {
        Name = "${local.name_prefix}-public-subnet"
        Tier = "public"
    })
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.this.id
    cidr_block = var.private_subnet_cidr
    availability_zone = local.az

    tags = merge(var.common_tags, {
        Name = "${local.name_prefix}-private-subnet"
        Tier = "private"
    })  
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id

    tags = merge(var.common_tags, {
        Name = "${local.name_prefix}-public-route-table"
    })
}

resource "aws_route" "public_internet" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.this.id

    tags = merge(var.common_tags, {
        Name = "${local.name_prefix}-private-route-table"
    })
}

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}