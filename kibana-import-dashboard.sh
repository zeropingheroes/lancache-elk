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

import_dashboard() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Error: File '$file' does not exist."
    return 1
  fi
  echo "Importing dashboard from $file..."
  curl --user "$KIBANA_USERNAME:$KIBANA_PASSWORD" \
       --silent --show-error \
       --request POST "$KIBANA_URL/api/saved_objects/_import?overwrite=true" \
       --header "kbn-xsrf: true" \
       --form file=@"$file"
  echo
  echo "Import complete for $file."
}

if [[ $# -eq 0 ]]; then
  # No arguments: import all .ndjson files in dashboards/
  if [[ ! -d dashboards ]]; then
    echo "Error: dashboards directory does not exist."
    exit 1
  fi
  shopt -s nullglob
  files=(dashboards/*.ndjson)
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No .ndjson files found in dashboards directory."
    exit 0
  fi
  for file in "${files[@]}"; do
    import_dashboard "$file"
  done
else
  # Import the specified file
  import_dashboard "$1"
fi
