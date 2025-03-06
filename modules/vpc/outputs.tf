output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_name" {
  value = var.vpc_name
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "app_inet_id" {
  value = aws_subnet.app_inet.id
}

output "db_inet_id" {
  value = aws_subnet.db_inet.id
}

output "app_db_inet_id" {
  value = aws_subnet.app_db_inet.id
}
