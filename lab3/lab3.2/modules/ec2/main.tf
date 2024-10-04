resource "aws_instance" "my-instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id       = var.subnet_id
  tags = {
    Name = "MiPrimerInstancia"
  }
}