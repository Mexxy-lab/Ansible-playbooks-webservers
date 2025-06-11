# 🧱 1. Terraform: Provision EC2 for Flask + Jenkins Agent

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "flask_app_instance" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "FlaskAppServer"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install docker.io -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

output "public_ip" {
  value = aws_instance.flask_app_instance.public_ip
}
