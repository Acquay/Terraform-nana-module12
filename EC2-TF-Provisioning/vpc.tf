resource "aws_vpc" "myapp-vpc" {
    cidr_block         = var.vpc_cidr_block

    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id            = aws_vpc.myapp-vpc.id
    cidr_block        = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-gateway" {
    vpc_id = aws_vpc.myapp-vpc.id
     tags = {
    Name: "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.myapp-vpc.id

    route {
    cidr_block = var.route_table_cidr_block
    gateway_id = aws_internet_gateway.myapp-gateway.id
  }

  tags = {
    Name: "${var.env_prefix}-rbt"
  }

}

resource "aws_route_table_association" "rbt-subnet-association" {
    subnet_id              = aws_subnet.myapp-subnet-1.id
    route_table_id         = aws_route_table.myapp-route-table.id
}

resource "aws_security_group" "myapp-sg" {
    name                   = "myapp-sg"
    vpc_id                 = aws_vpc.myapp-vpc.id

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    }

    ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    }

 
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.my_ip] # Allows all outbound traffic
    prefix_list_ids = []
  }

    tags = {
    Name: "${var.env_prefix}-sg"
  }


}