provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "VPC" {
  cidr_block       = "99.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Eng57.Stefan.Terra.VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "Stefan.Terra.IGW"
  }
}

module "app_tier" {
  source = "./modules/app_tier"

  vpc_id = aws_vpc.VPC.id
  my_ip = var.my_ip
  ssh_key_var = var.ssh_key
  igw_id = aws_internet_gateway.igw.id
  db_private_ip = aws_instance.DB.private_ip # var.db_priv_ip
}

# module "db_tier" {
#   source = "./modules/db_tier"
#
#   vpc_id = aws_vpc.VPC.id
#   my_ip = var.my_ip
#   ssh_key_var = var.ssh_key
# }

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "99.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Eng57.Stefan.Sub.Priv"
  }
}

resource "aws_security_group" "db_SG" {
  name        = "Stefan.Terra.DB.SG"
  description = "Allow http and https inbound traffic"
  vpc_id      = aws_vpc.VPC.id


  ingress {
    description = "app/db communication"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["99.0.1.0/24"]
  }

  ingress {
    description = "ssh from my ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Stefan.Terra.DB.SG"
  }
}

resource "aws_network_acl" "private_NACL" {
  vpc_id = aws_vpc.VPC.id
  subnet_ids = [aws_subnet.private.id]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "99.0.1.0/24"
    from_port  = 27017
    to_port    = 27017
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "99.0.1.0/24"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "Stefan.NACL.Priv"
  }
}

resource "aws_instance" "DB" {
  ami  = "ami-03b13f993274ce14a"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.db_SG.id]
  key_name = "Stefan_Terraform"

  tags = {
    Name = "Eng57.Stefan.DB.Terraform"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "Stefan_Terraform"
  public_key = var.ssh_key
}
