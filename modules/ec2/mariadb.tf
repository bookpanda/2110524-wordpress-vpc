resource "aws_network_interface" "eni_db_inet" {
  subnet_id       = var.db_inet_id
  private_ips     = ["10.0.2.100"] # static private IP, must be within the db_inet subnet CIDR range
  security_groups = [aws_security_group.sg_db_inet.id]
  tags = {
    Name = "${var.vpc_name}-eni_db_inet"
  }
}

resource "aws_network_interface" "eni_db_app_inet" {
  subnet_id       = var.app_db_inet_id
  private_ips     = ["10.0.3.100"] # static private IP, must be within the app_inet subnet CIDR range
  security_groups = [aws_security_group.sg_app_db_inet.id]
  tags = {
    Name = "${var.vpc_name}-eni_db_app_inet"
  }
}

resource "aws_instance" "mariadb" {
  ami           = var.ami
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.eni_db_inet.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.eni_db_app_inet.id
    device_index         = 1
  }

  key_name = aws_key_pair.generated_key_pair.key_name
  user_data = templatefile("${path.module}/install_mariadb.sh", {
    DB_NAME = "${var.database_name}"
    DB_USER = "${var.database_user}"
    DB_PASS = "${var.database_pass}"
  })

  tags = {
    Name = "${var.vpc_name}-mariadb"
  }
}

resource "aws_security_group" "sg_db_inet" {
  name        = "sg_db_inet"
  description = "Security group for db_inet subnet and EC2 instances"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # all outbound traffic
    cidr_blocks = ["0.0.0.0/0"] # go to nat gateway, according to route table
  }
}

resource "aws_security_group" "sg_app_db_inet" {
  name        = "sg_db_app"
  description = "Security group for communication between wordpress and mariadb"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24"] # allow ssh between ec2 in app_db subnets (only via eni) 
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24"] # allow traffic between ec2 in app_db subnets (only via eni)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
