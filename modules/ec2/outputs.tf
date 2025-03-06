output "app_inet_eip" {
  value = aws_eip.app_inet_eip.public_ip
}
