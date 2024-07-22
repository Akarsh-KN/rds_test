#create rds instance
resource "aws_db_instance" "demo-rds" {
    allocated_storage      = 10
    engine                 = "mysql"
    engine_version         = "5.7"
    instance_class         = "db.t3.micro"
    db_name                = "demodb"
    username               = "admin"
    password               = "password"
    parameter_group_name   = "default.mysql5.7"
    skip_final_snapshot    = true
    vpc_security_group_ids = [aws_security_group.demo-db-sg.id]
    db_subnet_group_name   = aws_db_subnet_group.demo-subnet-group.name
}



#create subnet group
resource "aws_db_subnet_group" "demo-subnet-group" {
  name       = "demo-subnet-group"
  subnet_ids = [aws_subnet.private_subnets_app[0].id, aws_subnet.private_subnets_app[1].id]
}

#create security group for the rds
resource "aws_security_group" "demo-db-sg" {
  name   = "demo-db-sg"
  vpc_id = aws_vpc.demo-vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.demo-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "demo-db-sg"
  }
}





