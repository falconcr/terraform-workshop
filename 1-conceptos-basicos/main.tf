resource "aws_instance" "my-instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "MiPrimerInstancia"
  }
}