variable "region" {
  description = "The region in which the VPC will be created"
  type        = string
}

variable "availability_zone" {
  description = "The availability zone in which the VPC will be created"
  type        = string
}

variable "ami" {
  description = "The AMI for the EC2 instance"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "database_name" {
  description = "The name of the database"
  type        = string
}

variable "database_user" {
  description = "The username for the database"
  type        = string
}

variable "database_pass" {
  description = "The password for the database"
  type        = string
}

variable "admin_user" {
  description = "The username for the wordpress admin"
  type        = string
}

variable "admin_pass" {
  description = "The password for the wordpress admin"
  type        = string
}

variable "key_name" {
  description = "The key pair name for the EC2 instance"
  type        = string
  default     = "cloud-computing"
}
