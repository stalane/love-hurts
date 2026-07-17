#!/bin/sh
# verify-sources.sh — Verify integrity of romance scam statistics source documents
#
# Downloads each source URL referenced in data/romance-scam-statistics.json,
# computes its SHA-256 hash, and compares against known-good hashes stored in
# scripts/source-hashes.sha256.
#
# Exit codes:
#   0 — all sources verified or no changes detected
#   1 — one or more sources have changed (manual review required)
#   2 — one or more sources are unreachable
#   3 — missing dependencies (jq, curl, sha256sum)

set -u

DATASET="data/romance-scam-statistics.json"
HASHFILE="scripts/source-hashes.sha256"
DOWNLOAD_DIR=$(mktemp -d /tmp/romance-scam-verify.XXXXXX)
trap 'rm -rf "$DOWNLOAD_DIR"' EXIT

RC=0

if ! command -v jq >/dev/null 2>&1; then
    echo "FATAL: jq is required but not installed."
    echo "  Debian/Ubuntu: apt install jq"
    echo "  macOS: brew install jq"
    exit 3
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "FATAL: curl is required but not installed."
    exit 3
fi

if ! command -v sha256sum >/dev/null 2>&1; then
    # macOS: use shasum -a 256
    if command -v shasum >/dev/null 2>&1; then
        sha256sum() { shasum -a 256 "$@"; }
    else
        echo "FATAL: sha256sum or shasum is required but not installed."
        exit 3
    fi
fi

echo "=== Romance Scam Statistics — Source Integrity Check ==="
echo "Dataset: $DATASET"
echo "Hash file: $HASHFILE"
echo ""

urls=$(jq -r '
    (.stats_cles[] | .url // empty),
    (.tendances[] | .url // empty)
' "$DATASET" 2>/dev/null | grep -E '^https?://' | sort -u)

if [ -z "$urls" ]; then
    echo "ERROR: Could not extract URLs from $DATASET"
    exit 2
fi

status_ok=0
status_changed=0
status_gone=0
status_new=0

for url in $urls; do
    # Create a safe, deterministic filename from the URL
    filename=$(printf "%s" "$url" | sha256sum | cut -d' ' -f1)
    filepath="$DOWNLOAD_DIR/$filename"

    echo "  Source: $url"

    # Download (use browser-like User-Agent to avoid WAF blocks)
    set +e
    http_status=$(curl -sL -o "$filepath" -w "%{http_code}" \
        --user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36" \
        --connect-timeout 15 --max-time 60 \
        "$url" 2>/dev/null)
    curl_rc=$?
    set -e

    if [ $curl_rc -ne 0 ] || [ "$http_status" -ge 400 ]; then
        echo "           ⚠  GONE (HTTP $http_status, curl exit $curl_rc)"
        status_gone=$((status_gone + 1))
        RC=2
        continue
    fi

    hash=$(sha256sum "$filepath" | cut -d' ' -f1)

    if [ -f "$HASHFILE" ]; then
        known=$(grep "$filename" "$HASHFILE" | awk '{print $1}' | head -1)
    else
        known=""
    fi

    if [ -z "$known" ]; then
        echo "           ✦ NEW   $hash  $filename"
        echo "             (not yet in $HASHFILE — add with:)"
        echo "             echo \"$hash  $filename\" >> \"$HASHFILE\""
        status_new=$((status_new + 1))
    elif [ "$hash" = "$known" ]; then
        echo "           ✓ OK"
        status_ok=$((status_ok + 1))
    else
        echo "           ⚠  CHANGED"
        echo "             Expected: $known"
        echo "             Got:      $hash"
        status_changed=$((status_changed + 1))
        RC=1
    fi

    rm -f "$filepath"
done

echo ""
echo "=== Summary ==="
echo "  OK:      $status_ok"
echo "  CHANGED: $status_changed"
echo "  GONE:    $status_gone"
echo "  NEW:     $status_new"
echo ""

if [ $RC -eq 0 ]; then
    echo "All sources verified."
elif [ $RC -eq 1 ]; then
    echo "WARNING: One or more sources have changed. Review manually."
elif [ $RC -eq 2 ]; then
    echo "WARNING: One or more sources are unreachable."
fi

exit $RC
