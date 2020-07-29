

### Terminology

- providers
  location to as where resources will be applied
- resource
  "tasks" or additions/changes you want to apply

### Commands

`terraform init`
`terraform plan` - shows me what changes it plans to make
`terraform apply` - checks AWS for what already exists, then applies changes specified
`terraform destroy` - shuts down all infrastructure

###### "CANNOT GET POSTS"

## Journey to Posts

- launch/set up DB instance (using AMI of working DB)
- ensure mongod is running (ssh into it to be sure)
- ensure there are no firewalls
- ensure it's connected to the internet via route table/IGW

- launch App instance (using AMI of working App)
- ensure DB_HOST uses private IP of running DB (ssh into it to be sure)
- ensure there are no firewalls
- OR ensure app is explicitly listening to port 27017 via sec-group 
