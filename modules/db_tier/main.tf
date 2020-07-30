
resource "aws_subnet" "private" {
  vpc_id     = var.vpc_id
  cidr_block = "99.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag_name}.Sub.Private"
  }
}
resource "aws_security_group" "db_SG" {
  name        = "Stefan.Terra.DB.SG"
  description = "Allow http and https inbound traffic"
  vpc_id      = var.vpc_id


  ingress {
    description = "app/db communication"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    security_groups = [var.app_security_group_id]
    # cidr_blocks = ["99.0.1.0/24"]

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
    Name = "${var.tag_name}.DB.SG"
  }
}

resource "aws_network_acl" "private_NACL" {
  vpc_id = var.vpc_id
  subnet_ids = [aws_subnet.private.id]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.pub_subnet_cidrblock
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
    cidr_block = var.pub_subnet_cidrblock
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "${var.tag_name}.NACL.Priv"
  }
}

resource "aws_instance" "DB" {
  ami  = "ami-03b13f993274ce14a"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.db_SG.id]
  # key_name = "Stefan_Terraform"

  tags = {
    Name = "${var.tag_name}.DB"
  }
}
