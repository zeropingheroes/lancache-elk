#!/bin/bash

# Fail on any error
set -e

# Load variables
source .env

# Check required environment variables
if [[ -z "$ES_USERNAME" || -z "$ES_PASSWORD" ]]; then
  echo "Error: ES_USERNAME and ES_PASSWORD environment variables must be set."
  exit 1
fi

# Default Elasticsearch URL if not set
ES_URL="${ES_URL:-https://localhost:9200}"

import_template() {
  local file="$1"
  local name
  name=$(basename "$file" .json)

  if [[ ! -f "$file" ]]; then
    echo "Error: File '$file' does not exist."
    return 1
  fi

  echo "Importing index template '$name' from $file..."
  curl --user "$ES_USERNAME:$ES_PASSWORD" \
       --request PUT "$ES_URL/_index_template/$name" \
       --header 'Content-Type: application/json' \
       --data-binary "@$file" \
       --insecure \
       --silent \
       --show-error \
  | jq .
  echo
  echo "Import complete for $file."
}

if [[ $# -eq 0 ]]; then
  # No arguments: import all .json files in index-templates/
  if [[ ! -d index-templates ]]; then
    echo "Error: index-templates directory does not exist."
    exit 1
  fi
  shopt -s nullglob
  files=(index-templates/*.json)
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No .json files found in index-templates directory."
    exit 0
  fi
  for file in "${files[@]}"; do
    import_template "$file"
  done
else
  # Import the specified template by name
  file="index-templates/$1.json"
  import_template "$file"
fi
