output "secret_arn" {
  value = aws_secretsmanager_secret.app.arn
}

output "secret_keys" {
  value = nonsensitive(keys(var.app_secrets))
}