# create vaiable for the vpc name
variable "vpc_name" {
  type    = string
  default = "demo-vpc"
}


# create variable for vpc cidr
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}


# create variable for list of availability zones   
variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

#create public subnet
variable "public_subnets_web" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

#create private subnet app
variable "private_subnets_app" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

# create private subnet db
variable "private_subnets_db" {
  type    = list(string)
  default = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
}



