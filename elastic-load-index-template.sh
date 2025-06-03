#!/bin/bash

# Fail on any error
set -e

source .env

# Check required environment variables
if [[ -z "$ES_USERNAME" || -z "$ES_PASSWORD" ]]; then
  echo "Error: ES_USERNAME and ES_PASSWORD environment variables must be set."
  exit 1
fi

# Elasticsearch URL
ES_URL="${ES_URL:-https://localhost:9200}"

# Template file and template name
TEMPLATE_FILE="index-templates/zeropingheroes-lancache-elk.json"
TEMPLATE_NAME="zeropingheroes-lancache-elk"

# Check if the template file exists
if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "Error: Template file '$TEMPLATE_FILE' not found."
  exit 1
fi

# Upload the template
curl --user "$ES_USERNAME:$ES_PASSWORD" \
     --request PUT "$ES_URL/_index_template/$TEMPLATE_NAME" \
     --header 'Content-Type: application/json' \
     --data-binary "@$TEMPLATE_FILE" \
     --insecure \
     --silent \
     --show-error \
| jq .
