#!/usr/bin/env bash
# btrbk wrapper script with ntfy notifications
# Usage: btrbk-notify.sh <instance> <config-file>
#   instance: "daily" or "weekly" (used in notification titles)
#   config-file: path to btrbk config file

set -o pipefail

INSTANCE="${1:?Usage: btrbk-notify.sh <instance> <config-file>}"
CONFIG_FILE="${2:?Usage: btrbk-notify.sh <instance> <config-file>}"
NTFY_URL="https://ntfy.winchser.com/backup"

# Temporary file for btrbk output
OUTPUT_FILE=$(mktemp)
trap 'rm -f "$OUTPUT_FILE"' EXIT

# Run btrbk and capture output
echo "Starting btrbk ${INSTANCE} backup..."
if btrbk -c "$CONFIG_FILE" --progress run 2>&1 | tee "$OUTPUT_FILE"; then
    BTRBK_EXIT=0
else
    BTRBK_EXIT=$?
fi

# Parse btrbk output for summary
SNAPSHOTS_CREATED=$(grep '^\+\+\+' "$OUTPUT_FILE" 2>/dev/null | wc -l | tr -d ' ')
SNAPSHOTS_SENT=$(grep -E '^\*\*\*|^>>>' "$OUTPUT_FILE" 2>/dev/null | wc -l | tr -d ' ')
# Look for btrbk-specific error indicators (not just any word "error")
ERRORS=$(grep -E '^!!!|^ERROR' "$OUTPUT_FILE" 2>/dev/null | wc -l | tr -d ' ')
WARNINGS=$(grep '^WARNING' "$OUTPUT_FILE" 2>/dev/null | wc -l | tr -d ' ')

# Ensure numeric values (default to 0 if empty)
: "${SNAPSHOTS_CREATED:=0}"
: "${SNAPSHOTS_SENT:=0}"
: "${ERRORS:=0}"
: "${WARNINGS:=0}"

# Extract subvolume names that were processed
SUBVOLUMES=$(grep -oP '(?<=^/mnt/btrfs-root/)@home-\w+' "$OUTPUT_FILE" | sort -u | tr '\n' ', ' | sed 's/,$//')

# Build notification message
if [[ $BTRBK_EXIT -eq 0 && $ERRORS -eq 0 ]]; then
    # Success
    TITLE="✅ btrbk ${INSTANCE} backup successful"
    PRIORITY="default"
    TAGS="white_check_mark"
    
    MESSAGE="Snapshots created: ${SNAPSHOTS_CREATED}
Snapshots sent: ${SNAPSHOTS_SENT}"
    
    if [[ -n "$SUBVOLUMES" ]]; then
        MESSAGE="${MESSAGE}
Subvolumes: ${SUBVOLUMES}"
    fi
    
    if [[ $WARNINGS -gt 0 ]]; then
        MESSAGE="${MESSAGE}
Warnings: ${WARNINGS}"
    fi
else
    # Failure
    TITLE="❌ btrbk ${INSTANCE} backup FAILED"
    PRIORITY="high"
    TAGS="x"
    
    # Extract last few error lines for context
    ERROR_CONTEXT=$(grep -E '^!!!|^ERROR|^WARNING' "$OUTPUT_FILE" | tail -5)
    
    MESSAGE="Exit code: ${BTRBK_EXIT}
Errors: ${ERRORS}
Warnings: ${WARNINGS}"

    if [[ -n "$SUBVOLUMES" ]]; then
        MESSAGE="${MESSAGE}
Subvolumes attempted: ${SUBVOLUMES}"
    fi

    if [[ -n "$ERROR_CONTEXT" ]]; then
        MESSAGE="${MESSAGE}

Recent errors:
${ERROR_CONTEXT}"
    fi
fi

# Send notification
curl -s \
    -H "Title: ${TITLE}" \
    -H "Priority: ${PRIORITY}" \
    -H "Tags: ${TAGS}" \
    -d "${MESSAGE}" \
    "$NTFY_URL"

# Exit with btrbk's exit code
exit $BTRBK_EXIT
