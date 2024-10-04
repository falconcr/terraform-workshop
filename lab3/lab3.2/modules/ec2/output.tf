output "vpc_id" {
  description = "The ID of the ec2 instance"
  value       = aws_instance.my-instance.id
}
