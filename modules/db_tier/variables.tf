variable "vpc_id" {
  description = "vpc id"
}

variable "tag_name" {
  description = "tag names"
}

variable "my_ip" {
  description = "my ip used to ssh in"
}

variable "ssh_key_var" {
  description = "keys to the kingdom"
}

variable "app_security_group_id" {
  description = "app sec-group id"
}

variable "pub_subnet_cidrblock" {
  description = "cidr block for public subnet"
}
