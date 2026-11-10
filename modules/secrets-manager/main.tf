resource "aws_secretsmanager_secret" "app" {
  name                    = "${var.environment}/node-app/env"
  recovery_window_in_days = 0

}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id     = aws_secretsmanager_secret.app.id
  secret_string = jsonencode(var.app_secrets)
}