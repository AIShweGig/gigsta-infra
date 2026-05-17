###############################################################
# Gigsta — basic AWS deployment.
#
# Topology (cheap & simple):
#   Single EC2 t3.small running docker-compose, Elastic IP,
#   Security group opens 22 (ssh), 80 (http), 443 (https reserved).
#   No load balancer, no RDS — SQLite on the EBS volume.
#
# When traffic grows, swap to:
#   - RDS Postgres (set DATABASE_URL env)
#   - ALB + multiple instances (frontend stateless, backend stateless)
#   - Cloudfront in front of ALB for static caching
###############################################################

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Use the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Default VPC keeps things simple. If you want isolation, swap for a dedicated VPC.
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "gigsta" {
  name        = "${var.project}-sg"
  description = "Gigsta web SG"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidrs
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Project = var.project }
}

resource "aws_key_pair" "deploy" {
  count      = var.ssh_public_key == "" ? 0 : 1
  key_name   = "${var.project}-deploy"
  public_key = var.ssh_public_key
}

# Cloud-init: install Docker, then pull this infra repo's compose and run from
# published GHCR images. No source upload needed.
locals {
  user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail
    apt-get update
    apt-get install -y ca-certificates curl gnupg git
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" \
      > /etc/apt/sources.list.d/docker.list
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    systemctl enable --now docker

    mkdir -p /opt/gigsta
    cat > /opt/gigsta/.env <<ENV
    GHCR_OWNER=${var.ghcr_owner}
    TAG=${var.image_tag}
    SECRET_KEY=${var.secret_key}
    ADMIN_EMAIL=${var.admin_email}
    ADMIN_PASSWORD=${var.admin_password}
    ALLOWED_ORIGINS=*
    DOMAIN=${var.domain}
    LE_EMAIL=${var.le_email}
    ENV

    cat > /opt/gigsta/README <<TXT
    EC2 ready. To deploy:
      cd /opt/gigsta
      git clone https://github.com/${var.ghcr_owner}/gigsta-infra.git infra
      cd infra
      # If images are private, log in first:
      #   echo \$GHCR_TOKEN | docker login ghcr.io -u ${var.ghcr_owner} --password-stdin
      docker compose -f docker-compose.prod.yml --env-file ../.env up -d
    TXT
  EOT
}

resource "aws_instance" "gigsta" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.gigsta.id]
  key_name               = var.ssh_public_key == "" ? null : aws_key_pair.deploy[0].key_name
  user_data              = local.user_data

  root_block_device {
    volume_size = 16
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.project}-server"
    Project = var.project
  }
}

resource "aws_eip" "gigsta" {
  instance = aws_instance.gigsta.id
  domain   = "vpc"
  tags     = { Project = var.project }
}
