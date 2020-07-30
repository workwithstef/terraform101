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

resource "aws_lb" "app_load_balancer" {
  name = "Stefan-test-LB"
  internal = false
  load_balancer_type = "network"
  # security_groups = [module.app_tier.app_sec_group_id]
  subnets = [module.app_tier.public_subnet_id]

  tags = {
    Environment = "Stefan.production"
  }
}

resource "aws_lb_target_group" "targeter" {
  name     = "Stefan-tf-LB-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC.id
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  # port              = "443"
  port              = "80"
  # protocol          = "HTTPS"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targeter.arn
  }
}


resource "aws_launch_template" "app_image" {
  image_id      = var.app_ami
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "bar" {
  vpc_zone_identifier = [module.app_tier.public_subnet_id]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 1

  launch_template {
    id      = aws_launch_template.app_image.id
    version = "$Latest"
  }
  tag {
    key = "Name"
    value = "Reinforcements.Stefan"
    propagate_at_launch = true
  }
}


module "app_tier" {
  source = "./modules/app_tier"

  vpc_id = aws_vpc.VPC.id
  my_ip = var.my_ip
  tag_name = var.name
  ssh_key_var = var.ssh_key
  web_image = var.app_ami
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
