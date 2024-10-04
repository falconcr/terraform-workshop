variable "instances" {
  type = map(string)
  default = {
    "web-server" = "t2.micro"
    "cache"      = "t2.small"
  }
}

resource "aws_instance" "example" {
  for_each = var.instances

  instance_type = each.value
  ami           = var.ami_id
  tags = {
    Name = each.key
  }
}


