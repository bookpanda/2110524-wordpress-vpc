resource "aws_network_interface" "eni_app_inet" {
  subnet_id       = var.app_inet_id
  private_ips     = ["10.0.1.100"] # static private IP, must be within the app_inet subnet CIDR range
  security_groups = [aws_security_group.sg_app_inet.id]
  tags = {
    Name = "${var.vpc_name}-eni_app_inet"
  }
}

resource "aws_eip" "app_inet_eip" {
  tags = {
    Name = "${var.vpc_name}-app-inet-eip"
  }
}

resource "aws_network_interface" "eni_app_db_inet" {
  subnet_id       = var.app_db_inet_id
  private_ips     = ["10.0.3.101"] # static private IP, must be within the db_inet subnet CIDR range
  security_groups = [aws_security_group.sg_app_db_inet.id]
  tags = {
    Name = "${var.vpc_name}-eni_app_db_inet"
  }
}

resource "aws_eip_association" "app_inet_eip_assoc" {
  allocation_id        = aws_eip.app_inet_eip.id
  network_interface_id = aws_network_interface.eni_app_inet.id
}

resource "aws_instance" "wordpress" {
  ami           = var.ami
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.eni_app_inet.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.eni_app_db_inet.id
    device_index         = 1
  }

  iam_instance_profile = var.s3_instance_profile_name

  key_name = aws_key_pair.generated_key_pair.key_name
  user_data = templatefile("${path.module}/install_wordpress.sh", {
    DB_NAME        = "${var.database_name}"
    DB_USER        = "${var.database_user}"
    DB_PASS        = "${var.database_pass}"
    DB_HOST        = "${aws_network_interface.eni_db_app_inet.private_ip}:3306"
    DB_PREFIX      = "wp_"
    WP_URL         = "http://${aws_eip.app_inet_eip.public_ip}"
    WP_ADMIN_USER  = "${var.admin_user}"
    WP_ADMIN_PASS  = "${var.admin_pass}"
    WP_ADMIN_EMAIL = "${var.admin_email}"
    WP_TITLE       = "Cloud"
    REGION         = "${var.region}"
    BUCKET_NAME    = "${var.bucket_name}"
  })

  tags = {
    Name = "${var.vpc_name}-wordpress"
  }
}

resource "aws_security_group" "sg_app_inet" {
  name        = "sg_app_inet"
  description = "Security group for app_inet subnet and EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}
