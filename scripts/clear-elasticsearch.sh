#!/bin/bash

echo "Clearing everything stored in elasticsearch"
/usr/bin/curl -XDELETE 'http://localhost:9200/_all?pretty'
