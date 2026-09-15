#!/usr/bin/env bash
# Runs k6 load tests at 5/30/100 VU levels, extracts p90/p95/throughput/error-rate
# with jq, and writes the results into a markdown table inside README.md.
#
# Usage:
#   ./run_load_tests.sh [TARGET_URL] [DURATION]

set -euo pipefail

TARGET_URL="${1:-https://test.k6.io}"
TEST_DURATION="${2:-30s}"
SCRIPT="script.ts"
README="README.md"
RESULTS_DIR="results"
VU_LEVELS=(5 30 100)

mkdir -p "$RESULTS_DIR"

echo "Target: $TARGET_URL"
echo "Duration per stage: $TEST_DURATION"
echo ""

# --- 1. Run k6 for each VU level ---
for vus in "${VU_LEVELS[@]}"; do
  echo ">>> Running k6 with VUS=$vus ..."
  k6 run \
    --env VUS="$vus" \
    --env TARGET_URL="$TARGET_URL" \
    --env TEST_DURATION="$TEST_DURATION" \
    --summary-export="$RESULTS_DIR/result_${vus}.json" \
    "$SCRIPT"
  echo ""
done

# --- 2. Extract metrics with jq ---
declare -A P90 P95 THROUGHPUT ERROR_RATE

for vus in "${VU_LEVELS[@]}"; do
  file="$RESULTS_DIR/result_${vus}.json"

  P90[$vus]=$(jq -r '.metrics.http_req_duration.values["p(90)"] // 0' "$file")
  P95[$vus]=$(jq -r '.metrics.http_req_duration.values["p(95)"] // 0' "$file")
  THROUGHPUT[$vus]=$(jq -r '.metrics.http_reqs.values.rate // 0' "$file")
  ERROR_RATE[$vus]=$(jq -r '.metrics.http_req_failed.values.rate // 0' "$file")
done

# --- 3. Build the markdown table ---
TABLE="## Load Test Results\n\n"
TABLE+="| VU  | p90 (ms) | p95 (ms) | Throughput (req/s) | Error Rate |\n"
TABLE+="|-----|----------|----------|---------------------|------------|\n"

for vus in "${VU_LEVELS[@]}"; do
  p90=$(printf "%.1f" "${P90[$vus]}")
  p95=$(printf "%.1f" "${P95[$vus]}")
  tp=$(printf "%.2f" "${THROUGHPUT[$vus]}")
  err=$(printf "%.2f%%" "$(echo "${ERROR_RATE[$vus]} * 100" | bc -l)")
  TABLE+="| $vus | $p90 | $p95 | $tp | $err |\n"
done

TABLE+="\n**Test date:** $(date +%Y-%m-%d)\n"
TABLE+="**Target:** \`$TARGET_URL\`\n"
TABLE+="**Duration per stage:** $TEST_DURATION\n"

# --- 4. Insert/replace the table in README.md ---
MARKER_START="<!-- LOAD_TEST_RESULTS_START -->"
MARKER_END="<!-- LOAD_TEST_RESULTS_END -->"

if [ ! -f "$README" ]; then
  echo -e "$MARKER_START\n$TABLE$MARKER_END" > "$README"
  echo "Created $README with results table."
else
  if grep -q "$MARKER_START" "$README"; then
    # Replace content between markers
    awk -v start="$MARKER_START" -v end="$MARKER_END" -v table="$TABLE" '
      $0 ~ start {print start; print table; f=1; next}
      $0 ~ end {print end; f=0; next}
      !f {print}
    ' "$README" > "${README}.tmp" && mv "${README}.tmp" "$README"
    echo "Updated results table in $README."
  else
    {
      echo ""
      echo "$MARKER_START"
      echo -e "$TABLE"
      echo "$MARKER_END"
    } >> "$README"
    echo "Appended results table to $README."
  fi
fi

echo ""
echo "Done. See $README for the updated table."
