variable "instances" {
  type = map(string)
  default = {
    "web-server" = "t2.micro"
    "db-server"  = "t3.medium"
    "cache"      = "t2.small"
  }
}

resource "aws_instance" "example" {
  for_each = var.instances

  instance_type = each.value
  ami           = "ami-0c55b159cbfafe1f0"  # Esta es una AMI de ejemplo
  tags = {
    Name = each.key
  }
}


