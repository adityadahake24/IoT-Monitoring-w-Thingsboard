resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1b"
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ecs_vpc.id
}
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.ecs_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "subnet1_route" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.route_table.id
}
resource "aws_route_table_association" "subnet2_route" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.route_table.id
}