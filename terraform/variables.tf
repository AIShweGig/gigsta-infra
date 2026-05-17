variable "project" {
  description = "Project name used to tag/name resources."
  type        = string
  default     = "gigsta"
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ca-central-1"
}

variable "instance_type" {
  description = "EC2 instance size."
  type        = string
  default     = "t3.small"
}

variable "ssh_public_key" {
  description = "Your SSH public key (ssh-rsa AAAA…). Leave empty to skip key registration."
  type        = string
  default     = ""
}

variable "ssh_cidrs" {
  description = "CIDR blocks allowed for SSH. Restrict to your IP in production."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "secret_key" {
  description = "JWT signing secret. Set a long random value via TF_VAR_secret_key."
  type        = string
  sensitive   = true
}

variable "admin_email" {
  description = "Bootstrap admin user email."
  type        = string
  default     = "admin@gigsta.app"
}

variable "admin_password" {
  description = "Bootstrap admin password. Override via TF_VAR_admin_password."
  type        = string
  sensitive   = true
}

variable "ghcr_owner" {
  description = "GitHub owner/org that hosts the gigsta-backend & gigsta-frontend container images."
  type        = string
}

variable "image_tag" {
  description = "Container image tag to deploy (e.g. 'latest' or a git SHA)."
  type        = string
  default     = "latest"
}

variable "domain" {
  description = "Public domain for HTTPS (Caddy + Let's Encrypt). e.g. gigsta.app"
  type        = string
}

variable "le_email" {
  description = "Email used for Let's Encrypt registration."
  type        = string
}
