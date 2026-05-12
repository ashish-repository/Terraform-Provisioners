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
}

# Create EC2 Instance
resource "aws_instance" "server" {

  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  key_name      = "mumbai"

  tags = {
    Name = "Terraform-File-Provisioner"
  }

  # SSH Connection
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/ASHISH/Downloads/mumbai.pem")
    host        = self.public_ip
  }

  # Create local index.html automatically
  provisioner "local-exec" {

    command = <<EOT
echo ^<h1^>Hello from Terraform Local Exec Provisioner^</h1^> > index.html
EOT

    interpreter = ["PowerShell", "-Command"]
  }

  # Install Nginx
  provisioner "remote-exec" {

    inline = [
      "sudo dnf install nginx -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
  }

  # Copy file from local machine to EC2
  provisioner "file" {

    source      = "index.html"
    destination = "/tmp/index.html"
  }

  # Move file to Nginx location
  provisioner "remote-exec" {

    inline = [
      "sudo mv /tmp/index.html /usr/share/nginx/html/index.html"
    ]
  }
}

# Output Public IP
output "public_ip" {
  value = aws_instance.server.public_ip
}