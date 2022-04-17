resource "aws_api_gateway_rest_api" "api" {
  name = "aws-lambda-auth"
}

# Main path setup

resource "aws_api_gateway_resource" "auth" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "auth"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

# Hello resource

resource "aws_api_gateway_resource" "hello" {
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "hello"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "hello_get" {
  authorization = "CUSTOM"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.hello.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  authorizer_id = aws_api_gateway_authorizer.aws_lambda_auth.id
}

# API "hello get" integration with lambda function
resource "aws_api_gateway_integration" "hello_get" {
  http_method = aws_api_gateway_method.hello_get.http_method
  resource_id = aws_api_gateway_resource.hello.id
  rest_api_id = aws_api_gateway_rest_api.api.id

  # Internal integration always POST
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.auth_lambda.invoke_arn
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

# IAM

resource "aws_lambda_permission" "api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.auth_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.hello_get.http_method}${aws_api_gateway_resource.hello.path}"
}
