#!/bin/bash

set -e

echo "WARNING: This will permanently delete everything in /var/lib/filebeat/"
read -p "Are you sure you want to continue? [y/N] " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 1
fi

systemctl stop filebeat

rm -rf /var/lib/filebeat/

systemctl start filebeat
