resource "aws_vpc" "dunnhumby-vpc" {                # Creating VPC here
   cidr_block       = "${var.cidr_vpc}"     # Defining the CIDR block use 10.0.0.0/24 for demo
   instance_tenancy = "default"

tags = {
   Name = "dunnhumby-vpc"
 }
}
 
resource "aws_internet_gateway" "dunnhumby_igw" {    # Creating Internet Gateway
    vpc_id =  "${aws_vpc.dunnhumby-vpc.id}"               # vpc_id will be generated after we create VPC

tags = {
   Name = "dunnhumby-igw"
 }

}
 
resource "aws_subnet" "dunnhumby-subnet-public" {    # Creating Public Subnets

   vpc_id =  aws_vpc.dunnhumby-vpc.id
   cidr_block = "${var.public_subnets}"      # CIDR block of public subnets

tags = {
   Name = "dunnhumby-subnet-public"
 }
}
 
resource "aws_subnet" "dunnhumby-subnet-private" {
   vpc_id =  aws_vpc.dunnhumby-vpc.id
   cidr_block = "${var.private_subnets}"          # CIDR block of private subnets

tags = {
   Name = "dunnhumby-subnet-private"
 }

}
 
resource "aws_route_table" "dunnhumby-PublicRT" {    # Creating RT for Public Subnet
    vpc_id =  aws_vpc.dunnhumby-vpc.id
         route {
    cidr_block = "0.0.0.0/0"               # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.dunnhumby_igw.id
     }

tags = {
   Name = "dunnhumby-PublicRT"
 }
 
}
 
resource "aws_route_table" "dunnhumby-PrivateRT" {    # Creating RT for Private Subnet
   vpc_id = aws_vpc.dunnhumby-vpc.id
   route {
   cidr_block = "0.0.0.0/0"             # Traffic from Private Subnet reaches Internet via NAT Gateway
   nat_gateway_id = aws_nat_gateway.dunnhumby-NATgw.id
   }

tags = {
   Name = "dunnhumby-PrivateRT"
 }

}

resource "aws_route_table_association" "dunnhumby-PublicRTassociation" {
    subnet_id = aws_subnet.dunnhumby-subnet-public.id
    route_table_id = aws_route_table.dunnhumby-PublicRT.id

}

resource "aws_route_table_association" "dunnhumby-PrivateRTassociation" {
    subnet_id = aws_subnet.dunnhumby-subnet-private.id
    route_table_id = aws_route_table.dunnhumby-PrivateRT.id

}

resource "aws_eip" "dunnhumby-nateIP" {
   vpc   = true

tags = {
   Name = "dunnhumby-nateIP"
 }

}
 
resource "aws_nat_gateway" "dunnhumby-NATgw" {
   allocation_id = aws_eip.dunnhumby-nateIP.id
   subnet_id = aws_subnet.dunnhumby-subnet-public.id

tags = {
   Name = "dunnhumby-NATgw"
}

}

resource "aws_security_group" "dunnhumby-sg" {
  name        = "dunnhumby-sg"
  description = "dunnhumby-sg"
  vpc_id      = aws_vpc.dunnhumby-vpc.id

  ingress {
    description      = "Allow port ssh from outside"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

ingress {
    description = "Allow port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
   description = "Allow https connection"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "dunnhumby-sg"
  }
}