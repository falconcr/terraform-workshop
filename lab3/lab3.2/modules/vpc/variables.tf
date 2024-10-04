variable "cidr_block_vpc" {
  description = "cidr_block de la VPC"
  default     = "10.0.0.0/16"
}

variable "cidr_block_subnet" {
  description = "cidr_block de la subnet"
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "availability_zone"
  default     = "us-east-1a"
}
