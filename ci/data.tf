# Reference for the lambda created by serverless
data "aws_lambda_function" "auth_lambda" {
  function_name = "aws-lambda-custom-auth-dev-protected"
}

data "aws_lambda_function" "authorizer_lambda" {
  function_name = "aws-lambda-custom-auth-dev-authorizer"
}

data "aws_lambda_function" "oauth_lambda" {
  function_name = "aws-lambda-custom-auth-dev-oauth"
}
