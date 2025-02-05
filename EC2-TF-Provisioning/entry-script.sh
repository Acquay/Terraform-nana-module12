#!/bin/bash
sudo yum update -y 
sudo amazon-linux-extras enable docker
sudo yum install docker
sudo systemctl start docker
sudo systemctl enable docker 
sudo usermod -aG docker ec2-user
docker run -p 8080:80 nginx