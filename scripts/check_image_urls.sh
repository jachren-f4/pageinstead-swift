#!/bin/bash

# Script to validate all Amazon cover image URLs in quotes.json
# Tests each URL to ensure it returns a valid image (HTTP 200)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# File paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
QUOTES_JSON="$PROJECT_DIR/PageInstead/Resources/quotes.json"

# Counters
TOTAL=0
SUCCESS=0
FAILED=0
REDIRECTED=0

# Arrays to store results
FAILED_URLS=()
REDIRECTED_URLS=()

echo "============================================="
echo "  Amazon Cover Image URL Validator"
echo "============================================="
echo ""
echo "Checking: $QUOTES_JSON"
echo ""

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is not installed${NC}"
    echo "Install with: brew install jq"
    exit 1
fi

# Check if quotes.json exists
if [ ! -f "$QUOTES_JSON" ]; then
    echo -e "${RED}Error: quotes.json not found at $QUOTES_JSON${NC}"
    exit 1
fi

# Extract all coverImageURL values with their quote IDs
echo "Extracting image URLs from JSON..."
URLS=$(jq -r '.quotes[] | "\(.id)|\(.coverImageURL)"' "$QUOTES_JSON")

# Count total URLs
TOTAL=$(echo "$URLS" | wc -l | xargs)

echo "Found $TOTAL image URLs to check"
echo ""
echo "Testing URLs (this may take a few minutes)..."
echo ""

# Progress bar width
BAR_WIDTH=50

# Test each URL
CURRENT=0
while IFS='|' read -r ID URL; do
    CURRENT=$((CURRENT + 1))

    # Calculate progress percentage
    PERCENT=$((CURRENT * 100 / TOTAL))
    FILLED=$((CURRENT * BAR_WIDTH / TOTAL))
    EMPTY=$((BAR_WIDTH - FILLED))

    # Print progress bar
    printf "\rProgress: [%${FILLED}s%${EMPTY}s] %d%% (%d/%d)" \
        "$(printf '#%.0s' $(seq 1 $FILLED))" \
        "$(printf ' %.0s' $(seq 1 $EMPTY))" \
        "$PERCENT" "$CURRENT" "$TOTAL"

    # Test URL with curl
    # -s: silent
    # -o /dev/null: discard output
    # -w: write out format
    # -L: follow redirects
    # --max-time: timeout after 10 seconds
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 10 "$URL" 2>/dev/null || echo "000")

    if [ "$HTTP_CODE" = "200" ]; then
        SUCCESS=$((SUCCESS + 1))
    elif [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "307" ] || [ "$HTTP_CODE" = "308" ]; then
        # Redirect - might still work but worth noting
        REDIRECTED=$((REDIRECTED + 1))
        REDIRECTED_URLS+=("ID $ID: $URL (HTTP $HTTP_CODE)")
    else
        FAILED=$((FAILED + 1))
        FAILED_URLS+=("ID $ID: $URL (HTTP $HTTP_CODE)")
    fi
done <<< "$URLS"

echo "" # New line after progress bar
echo ""
echo "============================================="
echo "  Results Summary"
echo "============================================="
echo ""
echo -e "Total URLs tested:    $TOTAL"
echo -e "${GREEN}✓ Successful (200):   $SUCCESS${NC}"
echo -e "${YELLOW}⚠ Redirected (3xx):   $REDIRECTED${NC}"
echo -e "${RED}✗ Failed (4xx/5xx):   $FAILED${NC}"
echo ""

# Show redirected URLs if any
if [ ${#REDIRECTED_URLS[@]} -gt 0 ]; then
    echo "============================================="
    echo "  Redirected URLs (Still Work)"
    echo "============================================="
    echo ""
    for url in "${REDIRECTED_URLS[@]}"; do
        echo -e "${YELLOW}$url${NC}"
    done
    echo ""
fi

# Show failed URLs if any
if [ ${#FAILED_URLS[@]} -gt 0 ]; then
    echo "============================================="
    echo "  Failed URLs (Need Fixing)"
    echo "============================================="
    echo ""
    for url in "${FAILED_URLS[@]}"; do
        echo -e "${RED}$url${NC}"
    done
    echo ""
fi

# Exit with error code if any failures
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}✗ Validation failed: $FAILED broken URL(s) found${NC}"
    exit 1
else
    echo -e "${GREEN}✓ All URLs are valid!${NC}"
    if [ $REDIRECTED -gt 0 ]; then
        echo -e "${YELLOW}  Note: $REDIRECTED URL(s) use redirects (still functional)${NC}"
    fi
    exit 0
fi
