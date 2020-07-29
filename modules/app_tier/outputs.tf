output "app_sec_group_id" {
  description = "app security group id"
  value = aws_security_group.app_SG.id
}

output "public_subnet_cidrblock" {
  description = "cidr block ip for public subnet"
  value = aws_subnet.public.cidr_block
}
