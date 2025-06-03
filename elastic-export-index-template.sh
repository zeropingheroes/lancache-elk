#!/bin/bash

# Exit on any errors
set -e

# Load environment variables
source .env

# Check required environment variables
if [[ -z "$ELASTIC_USERNAME" || -z "$ELASTIC_PASSWORD" ]]; then
  echo "Error: ELASTIC_USERNAME and ELASTIC_PASSWORD environment variables must be set."
  exit 1
fi

# Default Elasticsearch URL if not set
ELASTIC_URL="${ELASTIC_URL:-https://localhost:9200}"

# Directory to save exports
EXPORT_DIR="index-templates"
mkdir -p "$EXPORT_DIR"

# Usage check
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <template_name>"
  exit 1
fi

TEMPLATE_NAME="$1"
OUTFILE="$EXPORT_DIR/${TEMPLATE_NAME}.json"

# Check if file exists
if [[ -f "$OUTFILE" ]]; then
  read -p "File $OUTFILE already exists. Overwrite? (y/N): " confirm
  case "$confirm" in
    [yY][eE][sS]|[yY])
      echo "Overwriting $OUTFILE..."
      ;;
    *)
      echo "Aborting export."
      exit 0
      ;;
  esac
fi

# Get the template
curl -k -sS -u "$ELASTIC_USERNAME:$ELASTIC_PASSWORD" \
  -X GET "$ELASTIC_URL/_index_template/$TEMPLATE_NAME" \
  -H 'Content-Type: application/json' \
  | jq '.index_templates[0].index_template' > "$OUTFILE"

echo "Template exported to $OUTFILE"
