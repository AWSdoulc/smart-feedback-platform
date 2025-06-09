########################
# DynamoDB Table
########################
resource "aws_dynamodb_table" "feedback" {
  name           = "feedback"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = "SmartFeedbackPlatform"
  }
}

########################
# IAM Role for Lambda
########################
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda_basic_execution"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "dynamodb_access" {
  name = "lambda_dynamodb_access"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan"
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.feedback.arn
      }
    ]
  })
}

########################
# Lambda Function
########################
resource "aws_lambda_function" "feedback_lambda" {
  function_name = var.lambda_function_name
  filename      = "lambda.zip"
  handler       = "main.handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec_role.arn

  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.feedback.name
    }
  }

  depends_on = [aws_iam_policy_attachment.lambda_basic_execution]
}

########################
# API Gateway (HTTP)
########################
resource "aws_apigatewayv2_api" "http_api" {
  name          = "feedback-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.feedback_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "feedback_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /feedback"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

########################
# Permission: API Gateway → Lambda
########################
resource "aws_lambda_permission" "api_invoke_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.feedback_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
