variable "vpc_id" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "ami" {
  type = string
}

variable "key_name" {
  type = string
}

variable "app_inet_id" {
  type = string
}

variable "db_inet_id" {
  type = string
}

variable "app_db_inet_id" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_user" {
  type = string
}

variable "database_pass" {
  type = string
}

variable "admin_user" {
  type = string
}

variable "admin_email" {
  type    = string
  default = "admin@example.com"
}

variable "admin_pass" {
  type = string
}

variable "region" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "s3_instance_profile_name" {
  type = string
}
