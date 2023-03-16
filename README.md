# terraform-apigw-lambda-with-github-pipelines
API Gateway -> Lambda -> Database with RDS proxy, fully terraformed. 

## TODO
- Github pipeline example for lambda and lambda example code.
- RDS and RDS proxy to be added.
- Support for nested APIs will be added soon.
- Secrets manager to hold db pwds to be created.
- Websockets integration example.

## Prerequisites
- Create a VPC with private and public subnets.
- Create a database and database proxy.
- Lambda artifacts need to be created in a S3 folder that follows the naming convention as described below

Item | Format
--- | ---
Bucket name | <<var.environment>>-<<var.app>>-artifacts-bucket<br />e.g. dev-myapp-artifacts-bucket
S3 key for the specific api lambda | api-artifacts/api-<<var.api_name>>-<<var.api_version>>.zip<br />e.g. api-artifacts/api-sample-71f290b6c769333d129921d1a63578069757f5f0.zip

## What does this script create
- API GW.
- API GW Stage.
- Lambdas.
- API GW and Lambda Proxy integration.
- API is a module with lambda so additional APIs can be created easily.
- NAT gateway with spot instances. If you have NAT already you can remove it from the code.



## Create a terraform workspace and set the following variables. 
You can also create a .tfvars file in your repo to set the versions and other static defaults. Passwords should be set as sensitive variables accessible to the terraform workspace.

### Following variables should be set in workspace variables

Variable Name | Description | Type
--- | --- | ---
environment | Environment Name (dev/test/uat etc) | -
AWS_ACCESS_KEY_ID | Terraform user access key id | sensitive
AWS_SECRET_ACCESS_KEY | Terraform user secret | sensitive
AWS_DEFAULT_REGION | Default AWS region | sensitive
db_password | Database password (for password based auth) | sensitive

### Following variables can be set as workspace variables or in tfvars file. You can specify the file location by setting the optional variable described below.

Variable Name | Description
--- | ---
TF_CLI_ARGS_plan | Optionally you can set this to the file name where all variables below as HCL variable pairs.<br />E.g. -var-file="env/dev.terraform.tfvars" <br />env/dev.terraform.tfvars, env/test.terraform.tfvars etc.
app | Application unique name
vpc_id | VPC Id
subnet_ids | Public subnet ids as list
private_subnet_ids | Private subnet ids as list
database | Database name
db_host | Database host (or db proxy host)
db_port | Database port (or db proxy port)
db_username | Database username

sample_api_version | Api version of sample api (GIT SHA of each api lambda)

For NAT only

Variable Name | Description
--- | ---
nat_enabled | 0 or 1 - to enable NAT
private_subnet_cidrs | Private subnet CIDRs as a list
private_route_table_ids | Private Route Table IDs as list

## How to add APIs

To add more apis simply extend the map in the meta.tf by adding the api meta block as needed and add respective versions to the workspace or your tfvars file.

```
    login : {
      "method" : "POST",
      "api_version" : var.login_api_version
    },
    logout : {
      "method" : "GET",
      "api_version" : var.logout_api_version
    },
    ...

```
