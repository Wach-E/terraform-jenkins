/******************************************************************************
* Subnets
*******************************************************************************/

/**

* A subnet is nothing more than a range of valid IP addresses. 
* For resiliency, these subnets will be deployed in different
* availability zones in the selected AWS region
*/

/*
* Public Subnet 
*/
/**
* A public subnet within our VPC that we can launch resources into that we
* want to be auto-assigned public ip addresses.  These resources will be
* exposed to the public internet, with public IPs, by default.  They go 
* the through the Internet Gateway.
*/
resource "aws_subnet" "public_subnets" {
  vpc_id = var.vpc_id

  count                   = length(var.availability_zones)
  cidr_block              = "10.0.${count.index * 2 + 1}.0/24"
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}_${var.author}_vpc/public_${count.index}_10.0.${count.index *
    2 + 1}.0_${element(var.availability_zones, count.index)}"
    Author = var.author
  }
}

/*
* Private Subnet 
*/
/** 
* A private subnet for pieces of the infrastructure that we don't want to be
* directly exposed to the public internet.  Infrastructure launched into this
* subnet will not have public IP addresses, and can access the public internet
* only through the route to the NAT Gateway.
*/
resource "aws_subnet" "private_subnets" {
  vpc_id = var.vpc_id

  count                   = length(var.availability_zones)
  cidr_block              = "10.0.${count.index * 2}.0/24"
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.env}_${var.author}_vpc/private_${count.index}_10.0.${count.index *
    2}.0_${element(var.availability_zones, count.index)}"
    Author = var.author
  }
}


/******************************************************************************
* Internet Gateway (IGW)
*******************************************************************************/

/**
* IGW maps the instance’s private IP address with
* an associated public or Elastic IP address (http://mng.bz/p9QG) and then routes
* traffic in and out of the subnet to the internet
*/

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags = {
    Name   = "${var.env}_${var.author}_vpc/igw"
    Author = var.author
  }
}


resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name   = "${var.env}_${var.author}_vpc/public_rtb"
    Author = var.author
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "eip_for_nat_gateway" {
  vpc = true

  tags = {
    Name   = "${var.env}_${var.author}_vpc/eip-nat"
    Author = var.author
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip_for_nat_gateway.id
  subnet_id     = element(aws_subnet.public_subnets.*.id, 0)

  tags = {
    Name   = "${var.env}_${var.author}_vpc/nat_gateway"
    Author = var.author
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name   = "${var.env}_${var.author}_vpc/private_rtb"
    Author = var.author
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}
