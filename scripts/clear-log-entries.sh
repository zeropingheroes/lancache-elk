#!/bin/bash

echo "Clearing all log entries stored in ELK"
/usr/bin/curl -XDELETE 'http://localhost:9200/filebeat-*'
printf "\r\n"

echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "ENSURE NGINX'S CACHE AND LOGS ARE ALSO CLEARED"
echo "OR KIBANA VISUALISATIONS WON'T ACCURATELY SHOW"
echo "ALL FILES THAT HAVE BEEN CACHED PREVIOUSLY... "
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
