output "wordpress_elastic_ip" {
  value = module.ec2.app_inet_eip
}
