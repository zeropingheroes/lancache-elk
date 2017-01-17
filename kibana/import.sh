#!/bin/bash

ELASTICSEARCH=http://localhost:9200
KIBANA_INDEX=".kibana"

BASEDIR=$(dirname "$0")

for file in $BASEDIR/visualisations/*.json
do
    name=`basename $file .json`
    echo "Loading visualization $name:"
    curl -XPUT $ELASTICSEARCH/$KIBANA_INDEX/visualization/$name?pretty \
        -d @$file || exit 1
    echo
done
