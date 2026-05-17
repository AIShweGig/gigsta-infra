.PHONY: help up down logs prod dev smoke backup restore tf-init tf-plan tf-apply tf-destroy validate

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

# ---------- Run from published images ----------
up:  ## Up from GHCR images (needs GHCR_OWNER + .env)
	docker compose --env-file .env up -d

down:  ## Stop the stack
	docker compose down

logs:  ## Tail logs
	docker compose logs -f --tail=200

prod:  ## Production stack with Caddy/HTTPS (needs DOMAIN, LE_EMAIL, GHCR_OWNER)
	docker compose -f docker-compose.prod.yml --env-file .env up -d

# ---------- Local dev from sibling source repos ----------
dev:  ## Build & run from ../gigsta-backend and ../gigsta-frontend
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build

# ---------- Ops ----------
smoke:  ## End-to-end smoke (override: make smoke URL=https://gigsta.app)
	@URL=$${URL:-http://localhost}; scripts/smoke.sh $$URL

backup:  ## Snapshot DB + uploads
	scripts/backup.sh

restore:  ## Restore from backup. Usage: make restore FILE=backups/gigsta-...db
	scripts/restore.sh $(FILE)

# ---------- Terraform ----------
tf-init:  ## terraform init
	cd terraform && terraform init

tf-plan:  ## terraform plan
	cd terraform && terraform plan

tf-apply:  ## terraform apply
	cd terraform && terraform apply

tf-destroy:  ## terraform destroy
	cd terraform && terraform destroy

# ---------- Validation ----------
validate:  ## Validate compose files + terraform fmt/validate
	docker compose -f docker-compose.yml config -q && echo "✓ docker-compose.yml"
	docker compose -f docker-compose.prod.yml config -q 2>/dev/null || echo "  (prod needs DOMAIN/LE_EMAIL set to fully validate)"
	cd terraform && terraform fmt -check -recursive && terraform validate || true
