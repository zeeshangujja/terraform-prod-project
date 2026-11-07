output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

# depends_on makes ECS wait until the listener exists
output "target_group_arn" {
  value      = aws_lb_target_group.this.arn
  depends_on = [aws_lb_listener.http]
}
output "alb_arn_suffix" {
  value = aws_lb.this.arn_suffix
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.this.arn_suffix
}