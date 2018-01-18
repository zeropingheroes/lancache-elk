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

# Add elastic apt repo if it does not already exist
if [[ ! -f /etc/apt/sources.list.d/elastic-6.x.list ]]; then
    echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
fi

# Install required packages
/usr/bin/add-apt-repository -y ppa:certbot/certbot
/usr/bin/apt update -y
/usr/bin/apt install -y elasticsearch \
                        logstash \
                        kibana \
                        default-jre \
                        nginx

# Configure Nginx as reverse proxy for Kibana
rm -f /etc/nginx/sites-enabled/default
ln -s $SCRIPT_DIR/configs/nginx/sites-available/kibana /etc/nginx/kibana
ln -s /etc/nginx/sites-available/kibana /etc/nginx/sites-enabled/kibana

# Configure logstash with the lancache pipeline
ln -s $SCRIPT_DIR/configs/logstash/lancache-pipeline.conf /etc/logstash/conf.d/lancache-pipeline.conf

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
