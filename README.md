# terraform-apigw-lambda-with-github-pipelines
API Gateway -> Lambda -> Database with RDS proxy, fully terraformed. 

## TODO
- Github pipeline example for lambda and lambda example code.
- RDS and RDS proxy to be added.
- Secrets manager to hold db pwds to be created.

## Prerequisites
- Create a VPC with private and public subnets.
- Create a database and database proxy.

## What does this script create
- API GW.
- API GW Stage.
- Lambdas.
- API GW and Lambda Proxy integration.
- API is a module with lambda so additional APIs can be created easily.
- NAT gateway with spot instances. If you have NAT already you can remove it from the code.
- Support for nested APIs will be added soon.


## Create a terraform workspace and set the following variables. 
You can also create a .tfvars file in your repo to set the versions and other static defaults. Passwords should be set as sensitive variables accessible to the terraform workspace.

### environment 
Environment Name (dev/test/uat etc)

### app
Application unique name

### vpc_id
VPC Id

### subnet_ids
Public subnet ids as list

### private_subnet_ids
Private subnet ids as list

### database
Database name

### db_host
Database host (or db proxy host)

### db_port
Database port (or db proxy port)

### db_username
Database username

### db_password
Database password (for password based auth)

### sample_api_version
Api version of sample api (GIT SHA of each api lambda)
