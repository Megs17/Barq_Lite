#!/bin/bash
set -euo pipefail

REPORT_DIR="/var/reports"
REPORT_FILE="$REPORT_DIR/cert-lite.txt"
CERT_DIR="/etc/ssl/patrol"

sudo mkdir -p /var/reports
sudo chown $USER:$USER /var/reports


# Truncate old report
echo "cert_name | NotAfter_date | days_remaining" > "$REPORT_FILE"


for cert in "$CERT_DIR"/*.crt; do
    if [[ -f "$cert" ]]; then
        cert_name=$(basename "$cert")
        
        # Extract NotAfter date
        notafter=$(openssl x509 -in "$cert" -noout -enddate | cut -d= -f2)
        
        # Convert to seconds since epoch
        expiry_epoch=$(date -d "$notafter" +%s)
        now_epoch=$(date +%s)
        
        # Calculate days remaining
        days_remaining=$(( (expiry_epoch - now_epoch) / 86400 ))
        
        echo "$cert_name | $notafter | $days_remaining" >> "$REPORT_FILE"
    fi
done
