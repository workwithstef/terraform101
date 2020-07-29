resource "aws_subnet" "public" {
  vpc_id     = var.vpc_id
  cidr_block = "99.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Eng57.Stefan.Sub.Pub"
  }
}

resource "aws_security_group" "app_SG" {
  name        = "Stefan.Terra.App.SG"
  description = "Allow http and https inbound traffic"
  vpc_id      = var.vpc_id


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
    Name = "Stefan.Terra.App.SG"
  }
}

resource "aws_network_acl" "public_NACL" {
  vpc_id = var.vpc_id
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

  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = var.my_ip
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "Stefan.NACL.Pub"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
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
  vars = {
    db_host = "${var.db_private_ip}"
  }
}

resource "aws_instance" "Web" {
  ami  = "ami-067df73fe6e724431"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app_SG.id]
  # key_name = "Stefan_Terraform"
  associate_public_ip_address = true
  user_data = data.template_file.initapp.rendered

  tags = {
    Name = "Eng57.Stefan.App.Terraform"
  }
}
