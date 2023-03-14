resource "aws_security_group" "app_lambda_sg" {
  name        = "${var.environment}-${var.app}-app-lambda-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  egress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 65535
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_api_gateway_rest_api" "api-gateway" {
  name        = "appname"
  description = "API gateway"
}

resource "aws_api_gateway_deployment" "gateway-deployment" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api-gateway.body))
  }

  variables = {
    commit_id = local.timestamp
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "gateway-stage" {
  deployment_id = aws_api_gateway_deployment.gateway-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api-gateway.id
  stage_name    = var.environment
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  stage_name  = aws_api_gateway_stage.gateway-stage.stage_name
  method_path = "*/*"

  settings {
    throttling_burst_limit = 500
    throttling_rate_limit  = 100
    metrics_enabled = true
  }
}

module "sample_api" {
  source                       = "./api/"
  app                          = var.app
  environment                  = var.environment
  subnet_ids                   = var.private_subnet_ids
  vpc_id                       = var.vpc_id
  app_sg_id                    = aws_security_group.app_lambda_sg.id
  api_name                     = "sample"
  api_version                  = var.sample_api_version
  lb_port                      = var.lb_port
  lb_protocol                  = var.lb_protocol
  api_gateway_execution_arn    = aws_api_gateway_rest_api.api-gateway.execution_arn
  method                       = "POST"
  rest_api_id                  = aws_api_gateway_rest_api.api-gateway.id
  rest_api_root_resource_id    = aws_api_gateway_rest_api.api-gateway.root_resource_id
  db_host                      = var.db_host
  database                     = var.database
  db_port                      = var.db_port
  db_username                  = var.db_username
  db_password                  = var.db_password
}