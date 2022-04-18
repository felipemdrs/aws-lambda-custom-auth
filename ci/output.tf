output "base_url" {
  value = aws_api_gateway_deployment.api.invoke_url
}

output "protected_lambda__invoke_arn" {
  value = data.aws_lambda_function.protected_lambda.invoke_arn
}
