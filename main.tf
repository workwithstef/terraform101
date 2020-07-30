provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "VPC" {
  cidr_block       = "99.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "${var.name}.VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "${var.name}.IGW"
  }
}



module "app_tier" {
  source = "./modules/app_tier"

  vpc_id = aws_vpc.VPC.id
  my_ip = var.my_ip
  tag_name = var.name
  ssh_key_var = var.ssh_key
  igw_id = aws_internet_gateway.igw.id
  db_private_ip = module.db_tier.priv_subnet_ip

}

module "db_tier" {
  source = "./modules/db_tier"

  vpc_id = aws_vpc.VPC.id
  my_ip = var.my_ip
  tag_name = var.name
  ssh_key_var = var.ssh_key
  app_security_group_id = module.app_tier.app_sec_group_id
  pub_subnet_cidrblock = module.app_tier.public_subnet_cidrblock
}




# resource "aws_key_pair" "deployer" {
#   key_name   = "Stefan_Terraform"
#   public_key = var.ssh_key
# }
