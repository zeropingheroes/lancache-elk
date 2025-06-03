#!/bin/bash

# Exit on any errors
set -e

# Load environment variables (edit as needed)
source .env

# Set defaults if not set in .env
ES_URL="${ES_URL:-https://localhost:9200}"
ES_USERNAME="${ES_USERNAME:-elastic}"
ES_PASSWORD="${ES_PASSWORD:-changeme}"

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
curl -k -sS -u "$ES_USERNAME:$ES_PASSWORD" \
  -X GET "$ES_URL/_index_template/$TEMPLATE_NAME" \
  -H 'Content-Type: application/json' \
  | jq '.index_templates[0].index_template' > "$OUTFILE"

echo "Template exported to $OUTFILE"
