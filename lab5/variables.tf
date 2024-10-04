variable "aws_region" {
  description = "La región de AWS donde se creará la instancia EC2"
  default     = "us-east-1"  # Puedes cambiar esto a la región que prefieras.
}

variable "ami_id" {
  description = "ID de la AMI que se utilizará para lanzar la instancia"
  default     = "ami-0ebfd941bbafe70c6"
}