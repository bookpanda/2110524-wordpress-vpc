resource "aws_route_table" "app_inet_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public RT for app_inet"
  }
}

resource "aws_route_table" "db_inet_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private RT for db_inet"
  }
}

resource "aws_route_table" "nat_gw_inet_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public RT for nat_gw"
  }
}

resource "aws_route_table_association" "app_inet_association" {
  subnet_id      = aws_subnet.app_inet.id
  route_table_id = aws_route_table.app_inet_rt.id
}

resource "aws_route_table_association" "db_inet_association" {
  subnet_id      = aws_subnet.db_inet.id
  route_table_id = aws_route_table.db_inet_rt.id
}

resource "aws_route_table_association" "nat_gw_inet_association" {
  subnet_id      = aws_subnet.nat_gw_inet.id
  route_table_id = aws_route_table.nat_gw_inet_rt.id
}

