#!/usr/bin/env bash
# End-to-end smoke test against a running Gigsta deployment.
#
# Usage:
#   scripts/smoke.sh                          # against http://localhost
#   scripts/smoke.sh http://gigsta.app        # against production
#   ADMIN_EMAIL=... ADMIN_PASSWORD=... scripts/smoke.sh
#
# Returns non-zero on the first failure.

set -euo pipefail

BASE="${1:-http://localhost}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@gigsta.app}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-ChangeMe123!}"

# Colors (no-color if not a tty)
if [ -t 1 ]; then
  GREEN='\033[32m'; RED='\033[31m'; CYAN='\033[36m'; RESET='\033[0m'
else
  GREEN=''; RED=''; CYAN=''; RESET=''
fi

PASS=0; FAIL=0
ok()  { echo -e "  ${GREEN}✓${RESET} $1"; PASS=$((PASS+1)); }
err() { echo -e "  ${RED}✗${RESET} $1"; FAIL=$((FAIL+1)); }
header() { echo -e "\n${CYAN}»${RESET} $1"; }

# Helpers
get_json() { curl -fsS "$@"; }
extract() { python3 -c "import sys, json; print(json.loads(sys.stdin.read())['$1'])"; }

echo -e "${CYAN}Gigsta smoke test — $BASE${RESET}"

header "Health"
if curl -fsS "$BASE/api/health" > /dev/null; then
  ok "GET /api/health"
else
  err "Health check failed — is the server up at $BASE?"
  exit 1
fi

header "Public reads"
NCATS=$(curl -fsS "$BASE/api/categories" | python3 -c "import sys, json; print(len(json.load(sys.stdin)))")
[[ "$NCATS" -ge 9 ]] && ok "GET /api/categories ($NCATS categories)" || err "expected ≥9 categories, got $NCATS"

NCREATORS=$(curl -fsS "$BASE/api/creators" | python3 -c "import sys, json; print(json.load(sys.stdin)['total'])")
[[ "$NCREATORS" -ge 1 ]] && ok "GET /api/creators ($NCREATORS approved)" || err "no approved creators visible"

NEVENTS=$(curl -fsS "$BASE/api/services?category=events" | python3 -c "import sys, json; print(len(json.load(sys.stdin)))")
ok "GET /api/services?category=events ($NEVENTS events)"

NPLANS=$(curl -fsS "$BASE/api/plans" | python3 -c "import sys, json; print(len(json.load(sys.stdin)))")
[[ "$NPLANS" -eq 3 ]] && ok "GET /api/plans (3 plans)" || err "expected 3 plans, got $NPLANS"

header "Admin login + queue"
TOK=$(curl -fsS -X POST "$BASE/api/auth/login" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}" \
  | extract access_token)
[[ -n "$TOK" ]] && ok "Admin login" || err "Admin login failed"

curl -fsS -H "Authorization: Bearer $TOK" "$BASE/api/admin/stats" > /dev/null && ok "GET /api/admin/stats" || err "stats failed"
curl -fsS -H "Authorization: Bearer $TOK" "$BASE/api/admin/verification-queue" > /dev/null && ok "GET /api/admin/verification-queue" || err "queue failed"

header "End-to-end booking"
EMAIL="smoke+$RANDOM@example.com"
TC=$(curl -fsS -X POST "$BASE/api/auth/signup" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"smoke12345\",\"name\":\"Smoke User\",\"role\":\"client\"}" \
  | extract access_token)
[[ -n "$TC" ]] && ok "Client signup ($EMAIL)" || err "signup failed"

SID=$(curl -fsS "$BASE/api/services" | python3 -c "import sys, json; print(json.load(sys.stdin)[0]['id'])")
BOOKING=$(curl -fsS -X POST "$BASE/api/bookings" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $TC" \
  -d "{\"service_id\": $SID, \"scheduled_at\": \"2026-12-01T18:00:00\", \"notes\":\"smoke\", \"payment_method\":\"pay_in_person\"}")
BID=$(echo "$BOOKING" | extract id)
[[ -n "$BID" ]] && ok "Booking created (id=$BID)" || err "booking failed"

header "CMS round-trip"
ORIG=$(curl -fsS "$BASE/api/cms/home.hero.title" | python3 -c "import sys, json; print(json.load(sys.stdin)['value'])")
NEW="smoke-$(date +%s)"
curl -fsS -X PUT -H "Authorization: Bearer $TOK" -H 'Content-Type: application/json' \
  "$BASE/api/admin/cms/home.hero.title" -d "{\"value\":\"$NEW\"}" > /dev/null
ACTUAL=$(curl -fsS "$BASE/api/cms/home.hero.title" | python3 -c "import sys, json; print(json.load(sys.stdin)['value'])")
[[ "$ACTUAL" = "$NEW" ]] && ok "CMS write+read ($NEW)" || err "CMS round-trip mismatch"
# restore
curl -fsS -X PUT -H "Authorization: Bearer $TOK" -H 'Content-Type: application/json' \
  "$BASE/api/admin/cms/home.hero.title" -d "{\"value\":\"$ORIG\"}" > /dev/null

echo
if [[ $FAIL -eq 0 ]]; then
  echo -e "${GREEN}All $PASS checks passed.${RESET}"
  exit 0
else
  echo -e "${RED}$FAIL failed, $PASS passed.${RESET}"
  exit 1
fi
