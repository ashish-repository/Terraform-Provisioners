provider "aws" {
  region = "ap-south-1"
}

# Fetch Latest Amazon Linux 2023 AMI
data "aws_ami" "latest_amazon_linux" {

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create EC2 Instance
resource "aws_instance" "server" {

  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  key_name      = "mumbai"

  tags = {
    Name = "Terraform-Provisioner-Server"
  }

  # SSH Connection
  connection {
    type = "ssh"
    user = "ec2-user"

    # Update this path according to your system
    private_key = file("C:/Users/ASHISH/Downloads/mumbai.pem")

    host = self.public_ip
  }

  # Execute commands on EC2
  provisioner "remote-exec" {

    inline = [
      "sudo dnf update -y",
      "sudo dnf install nginx -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
  }
}

# Output Public IP
output "server_public_ip" {
  value = aws_instance.server.public_ip
}

# Output Latest AMI ID
output "latest_ami_id" {
  value = data.aws_ami.latest_amazon_linux.id
}
