terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

# 1. CREAMOS EL GUARDIA DE SEGURIDAD (FIREWALL)
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"

  # Regla de ENTRADA (Inbound): Permitir tráfico HTTP (Puerto 80) desde cualquier lugar
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 0.0.0.0/0 significa "Todo el mundo"
  }

  # Regla de ENTRADA: Permitir SSH (Puerto 22) para que tú puedas entrar
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de SALIDA (Outbound): Permitir al servidor descargar cosas de internet (Docker, Updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 significa "Todos los protocolos"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. EL SERVIDOR (EC2) CON INSTRUCCIONES DE INICIO
resource "aws_instance" "app_server" {
  ami           = "ami-04b70fa74e45c3917" # Ubuntu 24.04
  instance_type = "t3.micro"

  # Le asignamos el guardia de seguridad que creamos arriba
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  # User Data: Script de Bash que se ejecuta AUTOMÁTICAMENTE al arrancar
  # Esto instalará Docker sin que tú muevas un dedo.
 user_data = <<-EOF
              #!/bin/bash
              # 1. Instalar Docker
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu

              # 2. Descargar y Correr tu App (Aquí ocurre la magia)
              # Le decimos que corra en el puerto 80 del servidor y apunte al 80 del contenedor
              sudo docker run -d -p 80:80 alvaroarroyov/inventory-api:v1
              EOF

  tags = {
    Name = "InventoryApp-DevOps-Project"
  }
}

# 3. OUTPUT: Dinos cuál es la IP al terminar
output "server_public_ip" {
  description = "La IP publica del servidor para conectarnos"
  value       = aws_instance.app_server.public_ip
}