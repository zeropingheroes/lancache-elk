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

import_discover_session() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Error: File '$file' does not exist."
    return 1
  fi
  echo "Importing discover session from $file..."
  curl --user "$KIBANA_USERNAME:$KIBANA_PASSWORD" \
       --silent --show-error \
       --request POST "$KIBANA_URL/api/saved_objects/_import?overwrite=true" \
       --header "kbn-xsrf: true" \
       --form file=@"$file"
  echo
  echo "Import complete for $file."
}

if [[ $# -eq 0 ]]; then
  # No arguments: import all .ndjson files in discover-sessions/
  if [[ ! -d discover-sessions ]]; then
    echo "Error: discover-sessions directory does not exist."
    exit 1
  fi
  shopt -s nullglob
  files=(discover-sessions/*.ndjson)
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No .ndjson files found in discover-sessions directory."
    exit 0
  fi
  for file in "${files[@]}"; do
    import_discover_session "$file"
  done
else
  # Import the specified file
  import_discover_session "$1"
fi
