#!/bin/bash

echo "Restarting ELK"

/bin/systemctl restart elasticsearch && /bin/systemctl restart kibana && /bin/systemctl restart logstash
