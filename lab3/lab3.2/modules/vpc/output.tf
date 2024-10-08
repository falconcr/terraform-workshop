output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main_vpc.id
}

output "vpc_subnet_id" {
  description = "The ID of the subnet"
  value       = aws_subnet.main_subnet.id
}
