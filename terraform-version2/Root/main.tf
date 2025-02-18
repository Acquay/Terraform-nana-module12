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
    cidr_block = "0.0.0.0/0"
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
    cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

 
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allows all outbound traffic
    prefix_list_ids = []
  }

    tags = {
    Name: "${var.env_prefix}-sg"
  }
}

  data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name" 
    values = [var.image_name]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

 output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
 }

output "ip_address" {
    value  = aws_instance.ec2-instance.public_ip
}
 
 resource "aws_key_pair" "ssh-key" {
  key_name = "myapp-key"
  public_key = file(var.public_key_location)

 }

 # Creating the ec2 instance with TF
 resource "aws_instance" "ec2-instance" {
  ami =  data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name =  aws_key_pair.ssh-key.key_name


  tags = {
    Name: "${var.env_prefix}-srv1"
  }
  
 }