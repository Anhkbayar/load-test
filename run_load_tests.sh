#!/usr/bin/env bash
# Runs a k6 load test using VUS from the environment,
# extracts p90/p95/throughput/error-rate with jq,
# and appends a row to the markdown table inside README.md.
#
# Usage:
#   VUS=5 ./run_load_tests.sh [TARGET_URL] [DURATION]
#
# Example:
#   VUS=30 ./run_load_tests.sh https://test.k6.io 30s

set -euo pipefail

TARGET_URL="${1:-https://test.k6.io}"
TEST_DURATION="${2:-30s}"
VUS="${VUS:-5}"

SCRIPT="script.ts"
README="README.md"
RESULTS_DIR="results"

mkdir -p "$RESULTS_DIR"

echo "Target: $TARGET_URL"
echo "VUs: $VUS"
echo "Duration: $TEST_DURATION"
echo ""

# --- 1. Run k6 ---
echo ">>> Running k6 with VUS=$VUS ..."

k6 run \
  --env VUS="$VUS" \
  --env TARGET_URL="$TARGET_URL" \
  --env TEST_DURATION="$TEST_DURATION" \
  --summary-export="$RESULTS_DIR/result_${VUS}.json" \
  "$SCRIPT"

echo ""

# --- 2. Extract metrics with jq ---
file="$RESULTS_DIR/result_${VUS}.json"

P90=$(jq -r '.metrics.http_req_duration["p(90)"] // 0' "$file")
P95=$(jq -r '.metrics.http_req_duration["p(95)"] // 0' "$file")
THROUGHPUT=$(jq -r '.metrics.http_reqs.rate // 0' "$file")
ERROR_RATE=$(jq -r '.metrics.http_req_failed.value // 0' "$file")

# --- 3. Format metrics into a table row ---
p90=$(printf "%.1f" "$P90")
p95=$(printf "%.1f" "$P95")
tp=$(printf "%.2f" "$THROUGHPUT")
err=$(printf "%.2f%%" "$(echo "$ERROR_RATE * 100" | bc -l)")

ROW="| $VUS | $TEST_DURATION | $p90 | $p95 | $tp | $err |"

# Static table header (written only once).
TABLE_HEADER="## Staged Load Test Results

| VU | Duration | p90 (ms) | p95 (ms) | Throughput (req/s) | Error Rate |
|----|----------|----------|----------|--------------------|------------|"

# --- 4. Append the row to the table in README.md ---
MARKER_START="<!-- LOAD_TEST_RESULTS_START -->"
MARKER_END="<!-- LOAD_TEST_RESULTS_END -->"

if [ ! -f "$README" ]; then
  {
    echo "$MARKER_START"
    echo "$TABLE_HEADER"
    echo "$ROW"
    echo "$MARKER_END"
  } > "$README"
  echo "Created $README with results table."
elif grep -q "$MARKER_START" "$README"; then
  awk -v end="$MARKER_END" -v row="$ROW" '
    $0 ~ end {
      while (n > 0 && buf[n] ~ /^[[:space:]]*$/) n--
      buf[++n] = row
      buf[++n] = $0
      next
    }
    { buf[++n] = $0 }
    END { for (i = 1; i <= n; i++) print buf[i] }
  ' "$README" > "${README}.tmp" && mv "${README}.tmp" "$README"
  echo "Appended row to results table in $README."
else
  {
    echo ""
    echo "$MARKER_START"
    echo "$TABLE_HEADER"
    echo "$ROW"
    echo "$MARKER_END"
  } >> "$README"
  echo "Appended results table to $README."
fi

echo ""
echo "Done. See $README for the updated table."
