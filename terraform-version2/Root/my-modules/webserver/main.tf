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