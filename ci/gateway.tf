resource "aws_api_gateway_rest_api" "api" {
  name = "aws-lambda-custom-auth"
}

# Hello resource

resource "aws_api_gateway_resource" "hello" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "hello"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "hello_get" {
  authorization    = "CUSTOM"
  http_method      = "GET"
  resource_id      = aws_api_gateway_resource.hello.id
  rest_api_id      = aws_api_gateway_rest_api.api.id
  authorizer_id    = aws_api_gateway_authorizer.aws_lambda_auth.id
  api_key_required = true
}

# API "hello get" integration with lambda function
resource "aws_api_gateway_integration" "hello_get" {
  http_method = aws_api_gateway_method.hello_get.http_method
  resource_id = aws_api_gateway_resource.hello.id
  rest_api_id = aws_api_gateway_rest_api.api.id

  # Internal integration always POST
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.protected_lambda.invoke_arn
}

# Oauth resource

resource "aws_api_gateway_resource" "auth" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "auth"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_resource" "oauth" {
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "oauth"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "oauth_post" {
  authorization    = "NONE"
  http_method      = "POST"
  resource_id      = aws_api_gateway_resource.oauth.id
  rest_api_id      = aws_api_gateway_rest_api.api.id
  api_key_required = true
}

# API "oauth post" integration with lambda function
resource "aws_api_gateway_integration" "oauth_post" {
  http_method = aws_api_gateway_method.oauth_post.http_method
  resource_id = aws_api_gateway_resource.oauth.id
  rest_api_id = aws_api_gateway_rest_api.api.id

  # Internal integration always POST
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.oauth_lambda.invoke_arn
}

# IAM

resource "aws_lambda_permission" "protected_lambda" {
  statement_id  = "AllowAPIGatewayInvoke__${data.aws_lambda_function.protected_lambda.function_name}"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.protected_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.hello_get.http_method}${aws_api_gateway_resource.hello.path}"
}

resource "aws_lambda_permission" "oauth_lambda" {
  statement_id  = "AllowAPIGatewayInvoke__${data.aws_lambda_function.oauth_lambda.function_name}"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.oauth_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.oauth_post.http_method}${aws_api_gateway_resource.oauth.path}"
}

# API deploy

resource "aws_api_gateway_deployment" "api" {
  # Change on each terrafor apply to trigger stage deploy
  stage_description = timestamp()
  rest_api_id       = aws_api_gateway_rest_api.api.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "v1"
}

# Setup API Key

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "aws_lambda_custom_auth_usage_plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.stage.stage_name
  }
}

resource "aws_api_gateway_api_key" "key" {
  name = "aws_lambda_custom_auth_key"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}

# Enable API Gateway logs

resource "aws_api_gateway_account" "gateway_account" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_api_gateway_method_settings" "api_settings" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled        = true
    data_trace_enabled     = true
    logging_level          = "INFO"

    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}

resource "aws_iam_role" "cloudwatch" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = aws_iam_role.cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
