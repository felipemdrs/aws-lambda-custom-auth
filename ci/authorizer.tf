resource "aws_api_gateway_authorizer" "aws_lambda_auth" {
  name        = "aws_lambda_auth_authorizer"
  rest_api_id = aws_api_gateway_rest_api.api.id

  authorizer_result_ttl_in_seconds = 10
  authorizer_uri                   = data.aws_lambda_function.authorizer_lambda.invoke_arn
  authorizer_credentials           = aws_iam_role.invocation_role.arn
}

resource "aws_iam_role" "invocation_role" {
  name = "api_gateway_auth_invocation"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM

resource "aws_iam_role_policy" "invocation_policy" {
  name = "aws_iam_role_policy__invocation_policy"
  role = aws_iam_role.invocation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${data.aws_lambda_function.authorizer_lambda.arn}"
    }
  ]
}
EOF
}
