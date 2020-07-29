### Terminology

- providers
  sets location to as where resources will be applied

- resource
  "tasks" or additions/changes you want to apply

- data
  many uses regarding files, namely allows you to run template_file shell scripts within your created instance

- variable
  can set variables in a separate variable.tf file which can be called in your main.tf file; used to abstract data and keep code DRY

- module
  Used to reference nested modules (main.tf files). Similar to Python OOP, can be used to call and set values when used in conjuction with variable.tf files

- output
  Used to store the result of a nested module task (i.e. aws_instance.private_ip) which can then be called through `module` and set as a variable.


### Bash Commands

`terraform init` - initializes Terraform
`terraform plan` - shows me what changes it plans to make
`terraform apply` - checks AWS for what already exists, then applies changes specified
`terraform destroy` - shuts down all infrastructure

### Documentation

Hashicorp has wonderfully extensive & modular Documentation on Terraform and its commands. Enjoy :)
