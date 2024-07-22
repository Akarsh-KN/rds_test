
# create key pair
resource "aws_key_pair" "my-key-pair" {
  key_name   = "example-key-pair"
  public_key = file("./keys/id_rsa.pub")
  tags = {
    Name = "my-key-pair"
  }
}



#create security group for jump host
resource "aws_security_group" "jump-sg" {
  name   = "jump-sg"
  vpc_id = aws_vpc.demo-vpc.id
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "jump-sg"
  }
}


# creat ec2 instance jump host in public subnet
resource "aws_instance" "jump_host" {
  ami                         = "ami-04a81a99f5ec58529"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.my-key-pair.key_name
  vpc_security_group_ids      = [aws_security_group.jump-sg.id]
  subnet_id                   = aws_subnet.public_subnets_web[0].id
  associate_public_ip_address = true
  tags = {
    Name = "jump_host"
  }
}



# create security group for the private subnet PHP instance
resource "aws_security_group" "demo-sg" {
  name   = "demo-sg"
  vpc_id = aws_vpc.demo-vpc.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.jump-sg.id]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jump-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "demo-sg"
  }
}



#create ec2 instance in private subnet
resource "aws_instance" "example1" {
  ami                         = "ami-04a81a99f5ec58529"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.my-key-pair.key_name
  vpc_security_group_ids      = [aws_security_group.demo-sg.id]
  subnet_id                   = aws_subnet.private_subnets_app[0].id
  associate_public_ip_address = false
  tags = {
    Name = "example1"
  }
}







# output public ip
output "instance_public_ip" {
  value = aws_instance.jump_host.public_ip
}

#output private ip
output "instance_private_ip" {
  value = aws_instance.example1.private_ip
}











