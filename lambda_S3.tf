provider "aws" {
  region = "eu-west-1"
}

resource "aws_lambda_function" "my_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_handler"
  role          = "arn:aws:iam::558850831704:role/LambdaS3FullAccess"
  handler       = "index.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  runtime = "python3.6"

  environment {
    variables = {
      foo = "bar"
    }
  }
}
