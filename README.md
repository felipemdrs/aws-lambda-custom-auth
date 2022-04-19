# aws-lambda-custom-auth

This project uses a combination of serverless and terraform to create a simple api thats generate
bearer token, validate and get simple data on protected route.

Continuos integrations has developed using Github actions. More detalis in `.github/worflows` folder.

## Terraform Cloud

Used to manage terraform state. https://app.terraform.io/

### Variables

After create your terraform cloud account and started new workspace. Same variables must be created to apply changes


`AWS_SECRET_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY`. Both generated in AWS IAM with programmatically access mode

## Github Actions


### Secrets

`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. See more information above.


`TF_API_TOKEN` generated in terraform cloud. `Settings > Tokens > Create an API token`


## Features

- API Gateway
- Provider
- Serverless
- CloudWatch
- API Key
- Lambda
- Lambda Authorizer
- Python 3.8
