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

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "99.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Eng57.Stefan.Sub.Pub"
  }
}

resource "aws_security_group" "app_SG" {
  name        = "Stefan.Terra.App.SG"
  description = "Allow http and https inbound traffic"
  vpc_id      = aws_vpc.VPC.id


  ingress {
    description = "https from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Stefan.Terra.App.SG"
  }
}

resource "aws_network_acl" "public_NACL" {
  vpc_id = aws_vpc.VPC.id
  subnet_ids = [aws_subnet.public.id]

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
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "Stefan.NACL.Pub"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "Stefan.Route.Pub"
  }
}

resource "aws_route_table_association" "app" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_route.id
}

data "template_file" "initapp" {
  template = file("./scripts/app/init.sh.tpl")
}

resource "aws_instance" "Web" {
  ami  = "ami-0c10f0faac62cce29"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app_SG.id]
  associate_public_ip_address = true
  user_data = data.template_file.initapp.rendered
  tags = {
    Name = "Eng57.Stefan.App.Terraform"
  }
}



# resource "aws_instance" "Bastion" {
#   ami  = "ami-089cc16f7f08c4457"
#   instance_type = "t2.micro"
#   associate_public_ip_address = true
#   tags = {
#     Name = "Eng57.Stefan.O.Terra.Bastion"
#   }
# }
