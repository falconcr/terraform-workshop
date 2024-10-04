# Crear VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.cidr_block_vpc
  tags = {
    Name = "MainVPC"
  }
}

# Crear Subnet dentro de la VPC
resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.cidr_block_subnet
  availability_zone =  var.availability_zone
  tags = {
    Name = "MainSubnet"
  }
}