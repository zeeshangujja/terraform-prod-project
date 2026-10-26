output "public_ip" {
  value = aws_instance.public.public_ip
}

output "private_ip" {
  value = aws_instance.private.private_ip
}

output "public_sg_id" {
  value = aws_security_group.public.id
}

output "private_sg_id" {
  value = aws_security_group.private.id
}