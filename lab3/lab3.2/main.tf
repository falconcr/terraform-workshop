
module "vpc-subnet" {
    source = "./modules/vpc"
    cidr_block_vpc = "10.0.0.0/16"
    cidr_block_subnet = "10.0.1.0/24"
    availability_zone = "us-east-1a"
}


module "ec2-instance" {
    source = "./modules/ec2"
    ami_id = "ami-0ebfd941bbafe70c6"
    instance_type = "t2.micro"
    subnet_id = module.vpc-subnet.vpc_subnet_id

    depends_on = [ module.vpc-subnet ]
}