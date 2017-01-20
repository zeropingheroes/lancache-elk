#!/bin/bash

ELASTICSEARCH=http://localhost:9200
KIBANA_INDEX=".kibana"

BASEDIR=$(dirname "$0")

for file in $BASEDIR/../kibana/visualisations/*.json
do
    name=`basename $file .json`
    echo "Loading visualization $name:"
    curl -XPUT $ELASTICSEARCH/$KIBANA_INDEX/visualization/$name?pretty \
        -d @$file || exit 1
    echo
done

for file in $BASEDIR/../kibana/dashboards/*.json
do
    name=`basename $file .json`
    echo "Loading visualization $name:"
    curl -XPUT $ELASTICSEARCH/$KIBANA_INDEX/dashboard/$name?pretty \
        -d @$file || exit 1
    echo
done
