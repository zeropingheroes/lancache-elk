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

# Output directory
EXPORT_DIR="data-views"
mkdir -p "$EXPORT_DIR"

# Usage check
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <data_view_id>"
  exit 1
fi

DATA_VIEW_ID="$1"

# Fetch the data view to get its name
RESPONSE=$(curl --user "$KIBANA_USERNAME:$KIBANA_PASSWORD" \
                --silent --show-error \
                --request GET "$KIBANA_URL/api/saved_objects/index-pattern/$DATA_VIEW_ID" \
                --header "kbn-xsrf: true")

DATA_VIEW_NAME=$(echo "$RESPONSE" | jq -r '.attributes.name')

if [[ "$DATA_VIEW_NAME" == "null" || -z "$DATA_VIEW_NAME" ]]; then
  echo "Error: Could not retrieve data view name for ID '$DATA_VIEW_ID'."
  exit 2
fi

# Sanitize the name for use as a filename
SAFE_NAME=$(echo "$DATA_VIEW_NAME" | tr -cd '[:alnum:]._-')
OUTFILE="$EXPORT_DIR/${SAFE_NAME}.ndjson"

# Export the data view using the Saved Objects API
curl --user "$KIBANA_USERNAME:$KIBANA_PASSWORD" \
     --silent --show-error \
     --request POST "$KIBANA_URL/api/saved_objects/_export" \
     --header "kbn-xsrf: true" \
     --header "Content-Type: application/json" \
     --data-raw '{
       "objects": [
         {
           "type": "index-pattern",
           "id": "'"$DATA_VIEW_ID"'"
         }
       ],
       "includeReferencesDeep": false
     }' \
     --output "$OUTFILE"

if [[ $? -eq 0 ]]; then
  echo "Data view exported to $OUTFILE"
else
  echo "Failed to export data view: $DATA_VIEW_ID"
  exit 3
fi
