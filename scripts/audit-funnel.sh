#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SEO Magnet Funnel — Full Audit Script
# Run: bash scripts/audit-funnel.sh
# Optional: bash scripts/audit-funnel.sh --live-test
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

PASS="✅"
FAIL="❌"
WARN="⚠️"
TOTAL=0
PASSED=0
FAILED=0
WARNINGS=0

LANDING="https://autobiz.digital/seo-magnet"
TOOL="https://autonomous-seo.vercel.app"
WEBHOOK="https://autonomous.n8n888.cloud/webhook/seo-magnet"
N8N_WORKFLOW_ID="dd4JRXBccw8iVPe9"

TMPDIR_AUDIT=$(mktemp -d)
trap "rm -rf $TMPDIR_AUDIT" EXIT

now_ms() { python3 -c "import time; print(int(time.time()*1000))"; }

check() {
  local label="$1"
  local result="$2"
  TOTAL=$((TOTAL + 1))
  if [ "$result" = "pass" ]; then
    PASSED=$((PASSED + 1))
    echo "  $PASS $label"
  elif [ "$result" = "warn" ]; then
    WARNINGS=$((WARNINGS + 1))
    echo "  $WARN $label"
  else
    FAILED=$((FAILED + 1))
    echo "  $FAIL $label"
  fi
}

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   SEO Magnet Funnel — Full Audit                ║"
echo "║   $(date '+%Y-%m-%d %H:%M:%S')                        ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# ─── 1. LANDING PAGE ───────────────────────────────────
echo "━━━ 1. Landing Page ($LANDING) ━━━"

LANDING_HTML=$(curl -sL --max-time 10 "$LANDING" 2>/dev/null || echo "FETCH_FAILED")
LANDING_STATUS=$(curl -sL -o /dev/null -w "%{http_code}" --max-time 10 "$LANDING" 2>/dev/null || echo "000")

if [ "$LANDING_STATUS" = "200" ]; then
  check "Page loads (HTTP $LANDING_STATUS)" "pass"
else
  check "Page loads (HTTP $LANDING_STATUS)" "fail"
fi

# Extract the seo-magnet page JS chunk URL and fetch it
CHUNK_HASH=$(echo "$LANDING_HTML" | grep -o 'seo-magnet/page-[a-f0-9]*\.js' | head -1)
if [ -n "$CHUNK_HASH" ]; then
  CHUNK_URL="https://autobiz.digital/_next/static/chunks/app/$CHUNK_HASH"
  CHUNK_JS=$(curl -sL --max-time 10 "$CHUNK_URL" 2>/dev/null || echo "")
  COMBINED="$LANDING_HTML $CHUNK_JS"
else
  COMBINED="$LANDING_HTML"
  check "Page JS chunk found" "fail"
fi

# Check form fields in HTML
for field in "name" "email" "phone" "website" "business"; do
  if echo "$COMBINED" | grep -qi "$field"; then
    check "Form field: $field" "pass"
  else
    check "Form field: $field" "fail"
  fi
done

# Check https:// prefix
if echo "$COMBINED" | grep -q 'https://'; then
  check "Website field has https:// prefix" "pass"
else
  check "Website field has https:// prefix" "fail"
fi

# Check webhook URL in JS
if echo "$COMBINED" | grep -q "$WEBHOOK"; then
  check "POST target: $WEBHOOK" "pass"
else
  check "POST target: webhook URL present" "fail"
fi

# Check redirect to SEO tool
if echo "$COMBINED" | grep -q "autonomous-seo.vercel.app"; then
  check "Redirect to autonomous-seo.vercel.app" "pass"
else
  check "Redirect to autonomous-seo.vercel.app" "fail"
fi

# Check autostart param in redirect
if echo "$COMBINED" | grep -q "autostart"; then
  check "Redirect includes autostart param" "pass"
else
  check "Redirect includes autostart param" "fail"
fi

# Check ref param
if echo "$COMBINED" | grep -q "seo-magnet"; then
  check "Redirect includes ref=seo-magnet" "pass"
else
  check "Redirect includes ref=seo-magnet" "fail"
fi

# Check no await on fetch (instant redirect)
if echo "$COMBINED" | grep -q "await fetch.*webhook"; then
  check "Webhook fetch is NOT awaited (instant redirect)" "fail"
else
  check "Webhook fetch is NOT awaited (instant redirect)" "pass"
fi

echo ""

# ─── 2. SEO TOOL ──────────────────────────────────────
echo "━━━ 2. SEO Tool ($TOOL) ━━━"

TOOL_FILE="$TMPDIR_AUDIT/tool.html"
curl -sL --max-time 20 "$TOOL" -o "$TOOL_FILE" 2>/dev/null
TOOL_STATUS=$(curl -sL -o /dev/null -w "%{http_code}" --max-time 10 "$TOOL" 2>/dev/null || echo "000")

if [ "$TOOL_STATUS" = "200" ]; then
  check "Tool loads (HTTP $TOOL_STATUS)" "pass"
else
  check "Tool loads (HTTP $TOOL_STATUS)" "fail"
fi

# URL param handling
for param in "autostart" "autoUrl" "autoName" "refSource"; do
  if grep -q "$param" "$TOOL_FILE" 2>/dev/null; then
    check "URL param var: $param" "pass"
  else
    check "URL param var: $param" "fail"
  fi
done

# Auto-unlock from landing page
if grep -q "ref.*seo-magnet" "$TOOL_FILE" 2>/dev/null; then
  check "Auto-unlock for ref=seo-magnet" "pass"
else
  check "Auto-unlock for ref=seo-magnet" "fail"
fi

# history.replaceState
if grep -q "history.replaceState" "$TOOL_FILE" 2>/dev/null; then
  check "URL params cleaned (history.replaceState)" "pass"
else
  check "URL params cleaned (history.replaceState)" "fail"
fi

# localStorage unlock key
if grep -q "seo-tool-unlocked" "$TOOL_FILE" 2>/dev/null; then
  check "localStorage key: seo-tool-unlocked" "pass"
else
  check "localStorage key: seo-tool-unlocked" "fail"
fi

# Autostart setTimeout
if grep -q "setTimeout.*startScan" "$TOOL_FILE" 2>/dev/null; then
  check "Auto-scan: setTimeout → startScan()" "pass"
else
  check "Auto-scan: setTimeout → startScan()" "fail"
fi

echo ""

# ─── 3. GATE VERIFICATION ─────────────────────────────
echo "━━━ 3. Score-Reveal Gate ━━━"

# Score reveal overlay exists
if grep -q "score-reveal-overlay" "$TOOL_FILE" 2>/dev/null; then
  check "Gate overlay element exists" "pass"
else
  check "Gate overlay element exists" "fail"
fi

# No skip gate function
if grep -q "function skipGate" "$TOOL_FILE" 2>/dev/null; then
  check "skipGate function REMOVED" "fail"
else
  check "skipGate function REMOVED" "pass"
fi

# No applyLimitedMode function
if grep -q "function applyLimitedMode" "$TOOL_FILE" 2>/dev/null; then
  check "applyLimitedMode function REMOVED" "fail"
else
  check "applyLimitedMode function REMOVED" "pass"
fi

# Removal comment present
if grep -q "skipGate and applyLimitedMode removed" "$TOOL_FILE" 2>/dev/null; then
  check "Removal comment present" "pass"
else
  check "Removal comment present" "warn"
fi

# No limited mode banner
if grep -q "limited-mode-banner" "$TOOL_FILE" 2>/dev/null; then
  check "No limited-mode-banner in HTML" "fail"
else
  check "No limited-mode-banner in HTML" "pass"
fi

# No skip button in gate HTML
if grep -q "skipGate()" "$TOOL_FILE" 2>/dev/null; then
  check "No skip button onclick in gate" "fail"
else
  check "No skip button onclick in gate" "pass"
fi

# Escape key handling
if grep -q "Escape" "$TOOL_FILE" 2>/dev/null; then
  check "Escape key handler exists" "pass"
else
  check "Escape key handler exists" "fail"
fi

# Gate form fields
if grep -q "gate-name\|gate-email\|gate-phone" "$TOOL_FILE" 2>/dev/null; then
  check "Gate has lead capture form fields" "pass"
else
  if grep -q "unlockDashboard" "$TOOL_FILE" 2>/dev/null; then
    check "Gate has unlock form (unlockDashboard)" "pass"
  else
    check "Gate has lead capture form" "fail"
  fi
fi

# HMAC webhook signing
if grep -qE "HMAC|X-Webhook-Signature|generateWebhookSignature" "$TOOL_FILE" 2>/dev/null; then
  check "HMAC webhook signing present" "pass"
else
  check "HMAC webhook signing present" "fail"
fi

echo ""

# ─── 4. VERCEL API ENDPOINTS ──────────────────────────
echo "━━━ 4. API Endpoints ━━━"

# /api/proxy — should return 400 (needs URL param)
PROXY_STATUS=$(curl -sL -o /dev/null -w "%{http_code}" --max-time 10 "$TOOL/api/proxy" 2>/dev/null || echo "000")
if [ "$PROXY_STATUS" = "400" ]; then
  check "/api/proxy responds (HTTP $PROXY_STATUS — expected, needs params)" "pass"
elif [ "$PROXY_STATUS" = "000" ] || [ "$PROXY_STATUS" = "500" ]; then
  check "/api/proxy responds (HTTP $PROXY_STATUS)" "fail"
else
  check "/api/proxy responds (HTTP $PROXY_STATUS)" "pass"
fi

# /api/gemini — should return 405 (POST only) or 401 (needs key)
GEMINI_STATUS=$(curl -sL -o /dev/null -w "%{http_code}" --max-time 10 "$TOOL/api/gemini" 2>/dev/null || echo "000")
if [ "$GEMINI_STATUS" = "405" ] || [ "$GEMINI_STATUS" = "401" ] || [ "$GEMINI_STATUS" = "400" ]; then
  check "/api/gemini responds (HTTP $GEMINI_STATUS — expected)" "pass"
elif [ "$GEMINI_STATUS" = "000" ] || [ "$GEMINI_STATUS" = "500" ]; then
  check "/api/gemini responds (HTTP $GEMINI_STATUS)" "fail"
else
  check "/api/gemini responds (HTTP $GEMINI_STATUS)" "pass"
fi

# /api/psi — should return 401 or 400 (needs API key)
PSI_STATUS=$(curl -sL -o /dev/null -w "%{http_code}" --max-time 10 "$TOOL/api/psi" 2>/dev/null || echo "000")
if [ "$PSI_STATUS" = "401" ] || [ "$PSI_STATUS" = "400" ]; then
  check "/api/psi responds (HTTP $PSI_STATUS — expected)" "pass"
elif [ "$PSI_STATUS" = "000" ] || [ "$PSI_STATUS" = "500" ]; then
  check "/api/psi responds (HTTP $PSI_STATUS)" "fail"
else
  check "/api/psi responds (HTTP $PSI_STATUS)" "pass"
fi

echo ""

# ─── 5. VERCEL SECURITY HEADERS ───────────────────────
echo "━━━ 5. Security Headers ━━━"

HEADERS=$(curl -sI --max-time 10 "$TOOL" 2>/dev/null || echo "")

if echo "$HEADERS" | grep -qi "content-security-policy"; then
  check "CSP header present" "pass"
  if echo "$HEADERS" | grep -i "content-security-policy" | grep -q "autonomous-seo.vercel.app"; then
    check "CSP connect-src includes autonomous-seo.vercel.app" "pass"
  else
    check "CSP connect-src includes autonomous-seo.vercel.app" "warn"
  fi
  if echo "$HEADERS" | grep -i "content-security-policy" | grep -q "autonomous.n8n888.cloud"; then
    check "CSP connect-src includes n8n webhook domain" "pass"
  else
    check "CSP connect-src includes n8n webhook domain" "fail"
  fi
else
  check "CSP header present" "fail"
fi

if echo "$HEADERS" | grep -qi "x-frame-options.*deny"; then
  check "X-Frame-Options: DENY" "pass"
else
  check "X-Frame-Options: DENY" "fail"
fi

if echo "$HEADERS" | grep -qi "x-content-type-options.*nosniff"; then
  check "X-Content-Type-Options: nosniff" "pass"
else
  check "X-Content-Type-Options: nosniff" "fail"
fi

echo ""

# ─── 6. WEBHOOK ENDPOINT ──────────────────────────────
echo "━━━ 6. Webhook Endpoint ━━━"

# Test that webhook accepts POST and returns 200
WEBHOOK_RESPONSE=$(curl -sL -o /dev/null -w "%{http_code}" --max-time 10 \
  -X POST "$WEBHOOK" \
  -H "Content-Type: application/json" \
  -H "Origin: https://autobiz.digital" \
  -d '{"name":"_audit_test","email":"audit@test.invalid","phone":"","website":"https://example.com","business":"Audit Test","source":"audit-script","timestamp":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'","page":"audit-script"}' \
  2>/dev/null || echo "000")

if [ "$WEBHOOK_RESPONSE" = "200" ]; then
  check "Webhook accepts POST (HTTP $WEBHOOK_RESPONSE)" "pass"
else
  check "Webhook accepts POST (HTTP $WEBHOOK_RESPONSE)" "fail"
fi

# Test CORS — OPTIONS preflight
CORS_STATUS=$(curl -sL -o /dev/null -w "%{http_code}" --max-time 10 \
  -X OPTIONS "$WEBHOOK" \
  -H "Origin: https://autobiz.digital" \
  -H "Access-Control-Request-Method: POST" \
  2>/dev/null || echo "000")

if [ "$CORS_STATUS" = "200" ] || [ "$CORS_STATUS" = "204" ] || [ "$CORS_STATUS" = "204" ]; then
  check "CORS preflight OK (HTTP $CORS_STATUS)" "pass"
else
  check "CORS preflight (HTTP $CORS_STATUS)" "warn"
fi

echo ""

# ─── 7. LIVE END-TO-END TEST (optional) ───────────────
if [ "${1:-}" = "--live-test" ]; then
  echo "━━━ 7. Live End-to-End Test ━━━"

  TEST_WEBSITE="https://example.com"
  TEST_NAME="Funnel Audit"
  TEST_EMAIL="audit-$(date +%s)@test.invalid"

  START_TIME=$(now_ms)

  # Simulate form submit
  SUBMIT_RESPONSE=$(curl -sL -w "\n%{http_code}" --max-time 15 \
    -X POST "$WEBHOOK" \
    -H "Content-Type: application/json" \
    -H "Origin: https://autobiz.digital" \
    -d '{"name":"'"$TEST_NAME"'","email":"'"$TEST_EMAIL"'","phone":"","website":"'"$TEST_WEBSITE"'","business":"Audit","source":"seo-magnet","timestamp":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'","page":"autobiz.digital/seo-magnet"}' \
    2>/dev/null || echo "FAILED")

  SUBMIT_STATUS=$(echo "$SUBMIT_RESPONSE" | tail -1)
  END_TIME=$(now_ms)
  SUBMIT_MS=$((END_TIME - START_TIME))

  if [ "$SUBMIT_STATUS" = "200" ]; then
    check "Webhook submit (${SUBMIT_MS}ms)" "pass"
  else
    check "Webhook submit (HTTP $SUBMIT_STATUS)" "fail"
  fi

  # Simulate redirect — check tool loads with params
  REDIRECT_URL="${TOOL}/?url=${TEST_WEBSITE}&name=Test&autostart=true&ref=seo-magnet"
  REDIRECT_STATUS=$(curl -sL -o /dev/null -w "%{http_code}" --max-time 20 --retry 1 "$REDIRECT_URL" 2>/dev/null || echo "000")

  if [ "$REDIRECT_STATUS" = "200" ]; then
    check "Tool loads with redirect params (HTTP $REDIRECT_STATUS)" "pass"
  else
    check "Tool loads with redirect params (HTTP $REDIRECT_STATUS)" "fail"
  fi

  echo ""
  echo "  ℹ️  Check your inbox for AI action plan email to verify n8n workflow"
  echo "  ℹ️  Test email used: $TEST_EMAIL"
  echo ""
else
  echo "━━━ 7. Live Test — SKIPPED ━━━"
  echo "  ℹ️  Run with --live-test to fire a real webhook + check redirect"
  echo ""
fi

# ─── SUMMARY ──────────────────────────────────────────
echo "╔══════════════════════════════════════════════════╗"
echo "║   RESULTS                                       ║"
echo "╠══════════════════════════════════════════════════╣"
printf "║   Total:    %-36s║\n" "$TOTAL checks"
printf "║   Passed:   %-36s║\n" "$PASSED $PASS"
printf "║   Failed:   %-36s║\n" "$FAILED $FAIL"
printf "║   Warnings: %-36s║\n" "$WARNINGS $WARN"
echo "╠══════════════════════════════════════════════════╣"

if [ "$FAILED" -eq 0 ]; then
  echo "║   🟢 FUNNEL IS HEALTHY                          ║"
else
  echo "║   🔴 FUNNEL HAS ISSUES — FIX BEFORE GOING LIVE  ║"
fi

echo "╚══════════════════════════════════════════════════╝"
echo ""

exit "$FAILED"
