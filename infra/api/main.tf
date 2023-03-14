resource "aws_iam_role" "app_role" {
  name = "${var.environment}-${var.app}-${var.api_name}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  role = aws_iam_role.app_role.id
  name = "${var.environment}-${var.app}-${var.api_name}-cloudwatch-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances",
        "ec2:AttachNetworkInterface"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds-db:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda" {
  function_name    = "${var.environment}-${var.app}-${var.api_name}-lambda"
  description      = "test"
  role             = aws_iam_role.app_role.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.9"
  timeout          = 30
  s3_bucket        = "${var.environment}-${var.app}-artifacts-bucket"
  s3_key           = "api-artifacts/api-${var.api_name}-${var.api_version}.zip"

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [ var.app_sg_id ]
  }

  environment {
    variables = {
      DB_HOST        = var.db_host
      DB_PORT        = var.db_port
      DB_USERNAME    = var.db_username
      DB_PASSWORD    = var.db_password
      DATABASE       = var.database
    }
  }
}

resource "aws_lambda_alias" "lambda" {
  name             = "${var.environment}-${var.app}-${var.api_name}-lambda"
  description      = ""
  function_name    = aws_lambda_function.lambda.function_name
  function_version = "$LATEST"
}

resource "aws_api_gateway_resource" "gateway-resource" {
  rest_api_id = var.rest_api_id
  parent_id   = var.rest_api_root_resource_id
  path_part   = var.api_name
}

resource "aws_api_gateway_method" "gateway-method" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.gateway-resource.id
  http_method   = var.method
  authorization = "NONE"
}


resource "aws_api_gateway_method" "options" {
  rest_api_id      = var.rest_api_id
  resource_id      = aws_api_gateway_resource.gateway-resource.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.gateway-resource.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_gateway_execution_arn}/*/*"
}

resource "aws_api_gateway_integration" "api-integration" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.gateway-resource.id
  http_method             = aws_api_gateway_method.gateway-method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id          = var.rest_api_id
  resource_id          = aws_api_gateway_resource.gateway-resource.id
  http_method          = "OPTIONS"
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" : "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.gateway-resource.id
  http_method = aws_api_gateway_integration.options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,GET,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}