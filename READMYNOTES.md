# Terraform 101

- Hashicorp tool
- Used for Orchestration, in-line with Infrastructure as Code (IaC)

IaC:
- Configuration Management tools (Chef, Puppet, Ansible)
- Orchestration tools (Terraform, Cloudform, other.)

Combining both tools allows us to define our Infrastructure as Code

### Config Management

  Useful because they allow us to replicate changes across multiple servers (i.e. installing new packages). Since they can entirely provision machines, they make machines more immutable.

You should be able to terminate a machine, run a script, then recreate another machine in the exact same state as the previous machine

### Orchestration

This will create the Infrastructure. Not only the machine, but the networking, security, monitoring, and all setup around the machine that creates a production environment.

Example usage:
1. Automation server gets triggered
2. Tests run in machine created from AMI
3. Passing test triggers next step on automation server
4. New AMI created with previous AMI + new code
5. Calls terraform script to create infrastructure and deploy new AMI

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
