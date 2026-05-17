output "public_ip" {
  description = "Elastic IP of the Gigsta server. Point your DNS A-record here."
  value       = aws_eip.gigsta.public_ip
}

output "ssh_command" {
  description = "SSH command (uses your local key)."
  value       = "ssh ubuntu@${aws_eip.gigsta.public_ip}"
}

output "deploy_steps" {
  description = "Next steps to bring the stack up from published images."
  value       = <<-EOT
    1. Point DNS A-record for ${var.domain} at ${aws_eip.gigsta.public_ip}
    2. SSH in:   ssh ubuntu@${aws_eip.gigsta.public_ip}
    3. Deploy:
         cd /opt/gigsta
         git clone https://github.com/${var.ghcr_owner}/gigsta-infra.git infra
         cd infra
         # private images? docker login ghcr.io -u ${var.ghcr_owner} first
         docker compose -f docker-compose.prod.yml --env-file ../.env up -d
    4. Caddy gets a TLS cert on first request. Visit https://${var.domain}
  EOT
}
