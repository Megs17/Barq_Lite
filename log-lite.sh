#!/bin/bash
set -euo pipefail

LOG_DIR="/var/log/barq"
YESTERDAY="$(date -d "yesterday" +%F)"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Ensure main log file exists
touch "$LOG_DIR/barq.log"

# Rotate yesterday's log safely (copy + truncate)
if [[ -s "$LOG_DIR/barq.log" && ! -f "$LOG_DIR/barq-$YESTERDAY.log.gz" ]]; then
    cp "$LOG_DIR/barq.log" "$LOG_DIR/barq-$YESTERDAY.log"
    : > "$LOG_DIR/barq.log"
fi

# Compress yesterday’s log (if exists and not already compressed)
if [[ -f "$LOG_DIR/barq-$YESTERDAY.log" ]]; then
    gzip -f "$LOG_DIR/barq-$YESTERDAY.log"
fi

# Cleanup: keep only last 7 days based on filename
for f in "$LOG_DIR"/barq-*.log.gz; do
    # Extract date from filename
    file_date=$(basename "$f" | sed -E 's/barq-([0-9]{4}-[0-9]{2}-[0-9]{2})\.log\.gz/\1/')
    # Convert to seconds since epoch
    file_ts=$(date -d "$file_date" +%s)
    limit_ts=$(date -d "7 days ago" +%s)
    # Delete if older than 7 days
    if (( file_ts < limit_ts )); then
        rm -f "$f"
    fi
done

echo "Log rotation done. Active log: $LOG_DIR/barq.log"
