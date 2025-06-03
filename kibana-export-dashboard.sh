#!/bin/bash

# Fail on any error
set -e

# Load variables
source .env

# Check required environment variables
if [[ -z "$KIBANA_USERNAME" || -z "$KIBANA_PASSWORD" ]]; then
  echo "Error: KIBANA_USERNAME and KIBANA_PASSWORD environment variables must be set."
  exit 1
fi

# Default Kibana URL if not set
KIBANA_URL="${KIBANA_URL:-http://localhost:5601}"

# Dashboard ID must be supplied as the first argument
if [[ -z "$1" ]]; then
  echo "Usage: $0 <dashboard_id>"
  exit 1
fi

DASHBOARD_ID="$1"

# Query the dashboard to get its title
DASHBOARD_TITLE=$(curl --user "$KIBANA_USERNAME:$KIBANA_PASSWORD" \
  --silent \
  --request GET "$KIBANA_URL/api/saved_objects/dashboard/$DASHBOARD_ID" \
  --header "kbn-xsrf: true" | jq -r '.attributes.title')

if [[ "$DASHBOARD_TITLE" == "null" || -z "$DASHBOARD_TITLE" ]]; then
  echo "Error: Could not retrieve dashboard title for ID $DASHBOARD_ID"
  exit 1
fi

# Sanitize the title to create a safe filename
SAFE_TITLE=$(echo "$DASHBOARD_TITLE" | sed 's/[^[:alnum:]_-]/-/g')
OUTPUT_FILE="dashboards/${SAFE_TITLE}.ndjson"

# Create dashboards directory if it does not exist
mkdir -p dashboards

# Check if the output file already exists
if [[ -f "$OUTPUT_FILE" ]]; then
  read -p "File '$OUTPUT_FILE' already exists. Overwrite? [y/N]: " confirm
  case "$confirm" in
    [yY][eE][sS]|[yY]) ;;
    *) echo "Aborted."; exit 1 ;;
  esac
fi

# Export the dashboard
curl --user "$KIBANA_USERNAME:$KIBANA_PASSWORD" \
     --request POST "$KIBANA_URL/api/saved_objects/_export" \
     --header "kbn-xsrf: true" \
     --header "Content-Type: application/json" \
     --data '{
       "objects": [
         { "type": "dashboard", "id": "'"$DASHBOARD_ID"'" }
       ],
       "includeReferencesDeep": true
     }' \
     --no-progress-meter \
     --output "$OUTPUT_FILE"

echo "Dashboard $DASHBOARD_ID ('$DASHBOARD_TITLE') exported to $OUTPUT_FILE"
