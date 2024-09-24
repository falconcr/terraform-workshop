resource "aws_instance" "my-instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id       = aws_subnet.main_subnet.id
  tags = {
    Name = "MiPrimerInstancia"
  }
  # Dependencia explícita
  depends_on = [aws_subnet.main_subnet]
}