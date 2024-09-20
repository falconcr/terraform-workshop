output "instance_public_ip" {
  description = "La dirección IP pública de la instancia EC2"
  value       = aws_instance.my-instance.public_ip
}
