variable "aws_region" {
  description = "La región de AWS donde se creará la instancia EC2"
  default     = "us-east-1"  # Puedes cambiar esto a la región que prefieras.
}

variable "instance_type" {
  description = "El tipo de instancia EC2 que se va a crear"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "ID de la AMI que se utilizará para lanzar la instancia"
  default     = "ami-0ebfd941bbafe70c6"  # Esta es una AMI Amazon Linux 2 en la región us-west-2. Cambia según tu región.
}
