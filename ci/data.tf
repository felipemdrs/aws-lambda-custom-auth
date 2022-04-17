# Reference for the lambda created by serverless
data "aws_lambda_function" "auth_lambda" {
  function_name = "aws-lambda-auth-dev-hello"
}
