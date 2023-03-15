variable "environment" {}

variable "app" {}

variable "vpc_id" {}

variable "subnet_ids" {
  type = list
}

variable "private_subnet_ids" {
  type = list
}

variable "lb_port" {
  default = 443
}

variable "lb_protocol" {
  default = "TCP"
}

# Database host
variable "db_host" {}

# Database name
variable "database" {}

variable "db_port" {}

# Set as sensitive in terraform cloud
variable "db_username" {}

# Set as sensitive in terraform cloud
variable "db_password" {}

# Create a sample api lambda and supply version here
variable "sample_api_version" {}