# EC2 for running terraform
- name: terraform
- AMI: Amazon Linux 2023
- role: terraform-test

## Role
- name: terraform-test
- policies: AmazonEC2FullAccess, AmazonS3FullAccess, IAMFullAccess
```bash
ssh -i "cloud-computing.pem" ec2-user@ec2-13-215-193-114.ap-southeast-1.compute.amazonaws.com

sudo yum install -y yum-utils 
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform git
terraform -version 
```

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

# Flow
```bash
terraform plan
terraform apply
# show elastic address

chmod 400 wordpress-key.pem
ssh-keygen -R 54.251.49.12
ssh -i "wordpress-key.pem" ubuntu@54.251.49.12
sudo tail -f /var/log/cloud-init-output.log
php -v
cat ~/.ssh/authorized_keys

sudo nano wordpress-key.pem 
ssh -i "wordpress-key.pem" ubuntu@10.0.3.100
sudo mysql
cat ~/.ssh/authorized_keys

# go to aws, show ec2, s3, vpc, subnet, nat

# go to 54.251.49.12/wp-admin
# user: admin, pass: admin
# test upload image
```
TODO
- test tf apply on ec2: try diff region
- remove cloud-computing.pem