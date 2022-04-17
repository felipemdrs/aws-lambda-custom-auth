output "base_url" {
  value = aws_api_gateway_deployment.api.invoke_url
}

output "auth_lambda__invoke_arn" {
  value = data.aws_lambda_function.auth_lambda.invoke_arn
}
