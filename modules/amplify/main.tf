resource "aws_amplify_app" "frontend" {
  name         = "${var.environment}-frontend"
  repository   = var.repository_url
  access_token = var.github_token
  platform     = "WEB"

  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: dist
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  environment_variables = {
    VITE_API_URL = "/api"
  }

  # 1) Send /api/* to the ALB (must be first)
  custom_rule {
    source = "/api/<*>"
    target = "http://${var.api_domain}/api/<*>"
    status = "200"
  }

  # 2) React single-page-app fallback
  custom_rule {
    source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|woff2|ttf|map|json|webp)$)([^.]+$)/>"
    target = "/index.html"
    status = "200"
  }

}

resource "aws_amplify_branch" "main" {
  app_id            = aws_amplify_app.frontend.id
  branch_name       = var.branch_name
  framework         = "React"
  stage             = "PRODUCTION"
  enable_auto_build = true

}