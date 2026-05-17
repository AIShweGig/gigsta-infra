# Gigsta — Terraform deployment

Spins up a single EC2 t3.small with Docker + docker-compose installed,
an Elastic IP, and a security group opening 22/80/443.

## Quickstart

```bash
cd infra/terraform

# 1) Set required secrets (don't commit these)
export TF_VAR_secret_key="$(openssl rand -hex 32)"
export TF_VAR_admin_password="$(openssl rand -base64 16)"
export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"  # optional

# 2) Init + plan + apply
terraform init
terraform plan
terraform apply

# 3) Note the outputs (public_ip, ssh_command)

# 4) Ship the code (from project root)
cd ..   # back to /infra
scp -r ../backend ../frontend ../infra ubuntu@$(terraform -chdir=terraform output -raw public_ip):/opt/gigsta/

# 5) On the server, bring it up
ssh ubuntu@$(terraform -chdir=terraform output -raw public_ip)
cd /opt/gigsta/infra
sudo docker compose --env-file ../.env up -d --build

# 6) Visit http://<public_ip>
```

## When traffic grows

This is the minimal box for getting started. To scale:

- **Database**: switch `DATABASE_URL` from SQLite to RDS Postgres.
  Add a `psycopg2-binary` to `backend/requirements.txt` and uncomment in Dockerfile.
- **HA**: move frontend + backend behind an ALB; the backend is stateless.
- **TLS**: add Caddy or a Let's Encrypt sidecar — or terminate at an ALB.
- **Backups**: snapshot the EBS volume that holds `/data`.

## Tearing it down

```bash
terraform destroy
```
