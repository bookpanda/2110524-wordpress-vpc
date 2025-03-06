module "vpc" {
  source            = "./modules/vpc"
  availability_zone = var.availability_zone
}

module "ec2" {
  source                   = "./modules/ec2"
  vpc_id                   = module.vpc.vpc_id
  vpc_name                 = module.vpc.vpc_name
  ami                      = var.ami
  key_name                 = var.key_name
  app_inet_id              = module.vpc.app_inet_id
  db_inet_id               = module.vpc.db_inet_id
  app_db_inet_id           = module.vpc.app_db_inet_id
  database_name            = var.database_name
  database_user            = var.database_user
  database_pass            = var.database_pass
  admin_user               = var.admin_user
  admin_pass               = var.admin_pass
  region                   = var.region
  bucket_name              = var.bucket_name
  s3_instance_profile_name = module.s3.iam_instance_profile_name
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}
