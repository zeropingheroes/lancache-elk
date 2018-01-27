#!/bin/bash

# Exit if there is an error
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# If script is executed as an unprivileged user
# Execute it as superuser, preserving environment variables
if [ $EUID != 0 ]; then
    sudo -E "$0" "$@"
    exit $?
fi

# If there is an .env file use it
# to set the variables
if [ -f $SCRIPT_DIR/.env ]; then
    source $SCRIPT_DIR/.env
fi

# Add the elastic public key
/usr/bin/wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

# Add elastic apt repo if it does not already exist
if [[ ! -f /etc/apt/sources.list.d/elastic-6.x.list ]]; then
    echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
fi

# Install required packages
/usr/bin/apt update -y
/usr/bin/apt install -y default-jre
/usr/bin/apt install -y elasticsearch \
                        logstash \
                        kibana \
                        nginx

# Configure Nginx as reverse proxy for Kibana
rm -f /etc/nginx/sites-enabled/default
ln -s $SCRIPT_DIR/configs/nginx/kibana /etc/nginx/sites-available/kibana
ln -s /etc/nginx/sites-available/kibana /etc/nginx/sites-enabled/kibana

# Configure logstash with the lancache pipeline
cp $SCRIPT_DIR/configs/logstash/lancache-pipeline.conf /etc/logstash/conf.d/lancache-pipeline.conf

# Set the correct permissions on the logstash directory
chown -R logstash:root /etc/logstash/conf.d
chmod 0750 /etc/logstash/conf.d
chmod 0640 /etc/logstash/conf.d/*

# Load the new service file
/bin/systemctl daemon-reload

# Set services to start at boot
/bin/systemctl enable elasticsearch
/bin/systemctl enable logstash
/bin/systemctl enable kibana
/bin/systemctl enable nginx

# Start the services
/bin/systemctl start elasticsearch
/bin/systemctl start logstash
/bin/systemctl start kibana
/bin/systemctl start nginx

# Reload Nginx to pick up the new config
/bin/systemctl reload nginx

# Wait for Kibana to start
echo "Waiting for Kibana to start"
while ! curl --output /dev/null --silent --head --fail http://localhost:5601; do
  sleep 1 && echo -n .
done
echo "Kibana started"

# Import the Kibana index pattern
/usr/bin/curl -X POST \
              -H "Content-Type: application/json" \
              -H "kbn-xsrf: true" \
              -i -d@$SCRIPT_DIR/configs/kibana/index-pattern/lancache.json \
              "http://localhost:5601/api/saved_objects/index-pattern"

# Install Kibana importer
rm -rf /tmp/kibana-importer
/usr/bin/git clone https://github.com/mnp/kibana-importer.git /tmp/kibana-importer

# Import Kibana searches, visualisations and dashboards
/tmp/kibana-importer/kibana-importer.py --json $SCRIPT_DIR/configs/kibana/export.json --fix-idx
