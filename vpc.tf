# create vpc and public and private subnets
resource "aws_vpc" "demo-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = var.vpc_name
  }
}

#create 3 more public subnets for web
resource "aws_subnet" "public_subnets_web" {
  vpc_id     = aws_vpc.demo-vpc.id
  count      = length(var.public_subnets_web)
  cidr_block = element(var.public_subnets_web, count.index)

  tags = {
    "Name" = "public_subnet_${count.index + 1}"
  }
}


# create 3  more private subnets for app
resource "aws_subnet" "private_subnets_app" {
  vpc_id     = aws_vpc.demo-vpc.id
  count      = length(var.private_subnets_app)
  cidr_block = element(var.private_subnets_app, count.index)

  tags = {
    "Name" = "private_subnet_app_${count.index + 1}"
  }
}

# create 3 more private subnets for db
resource "aws_subnet" "private_subnets_db" {
  vpc_id     = aws_vpc.demo-vpc.id
  count      = length(var.private_subnets_db)
  cidr_block = element(var.private_subnets_db, count.index)

  tags = {
    "Name" = "private_subnet_db_${count.index + 1}"
  }
}


# create internet gateway
resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id
  tags = {
    "Name" = "demo-igw"
  }
}


# #attach internet gate way to vpc
# resource "aws_internet_gateway_attachment" "name" {
#   internet_gateway_id = aws_internet_gateway.demo-igw.id
#   vpc_id              = aws_vpc.demo-vpc.id
# }


#creae eip
resource "aws_eip" "lb" {
  depends_on = [aws_internet_gateway.demo-igw]
  # domain = "vpc"
}


# create NAT gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public_subnets_web[0].id
  depends_on    = [aws_internet_gateway.demo-igw]
  tags = {
    "Name" = "nat-gateway"
  }
}


# create route table for public subnet
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.demo-igw.id
  }

  tags = {
    "Name" = "rt_public"
  }
}



# subnet association with route table
resource "aws_route_table_association" "a" {
  count = length(aws_subnet.public_subnets_web)

  subnet_id      = aws_subnet.public_subnets_web[count.index].id
  route_table_id = aws_route_table.rt_public.id
}



# create route table for private subnet
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    "Name" = "rt_private"
  }
}


# subnet association with route table
resource "aws_route_table_association" "b" {
  count = length(aws_subnet.private_subnets_app)

  subnet_id      = aws_subnet.private_subnets_app[count.index].id
  route_table_id = aws_route_table.rt_private.id
}




# create route table for private subnet db
resource "aws_route_table" "rt_private_db" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    "Name" = "rt_private_db"
  }
}


# subnet association with route table
resource "aws_route_table_association" "c" {
  count = length(aws_subnet.private_subnets_db)

  subnet_id      = aws_subnet.private_subnets_db[count.index].id
  route_table_id = aws_route_table.rt_private_db.id
}
