variable "vpc_id" {
  description = "vpc id"
}

variable "my_ip" {
  description = "my ip used to ssh in"
}

variable "igw_id" {
  description = "internet gateway id"
}

variable "db_private_ip" {
  description = "private ip of db for DB_HOST env variable"
  
}

variable "ssh_key_var" {
  description = "keys to the palace"
}
