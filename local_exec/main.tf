terraform {
  required_version = "~> 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "server" {

  ami           = "i-0aaa632c24f0230f0"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo EC2 Created Successfully"
  }
}
