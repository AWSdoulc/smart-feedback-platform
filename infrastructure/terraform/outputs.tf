output "api_endpoint" {
  description = "URL of the deployed API Gateway endpoint"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}
