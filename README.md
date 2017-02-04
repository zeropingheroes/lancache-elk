# lancache-elk
Collect, process and visualise statistics from `zeropingheroes/lancache` with ELK

## Requirements

### ELK Server
* Ubuntu Server 16.04
* [ELK](https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-ubuntu-14-04)

### Lancache Server
* [`zeropingheroes/lancache`](https://github.com/zeropingheroes/lancache)
* [Filebeat](https://www.elastic.co/guide/en/beats/libbeat/5.1/setup-repositories.html)

## Installation

### On your Lancache server

Edit `install/filebeat/filebeat.yml` and ensure `output-logstash` is configured to ship logs to your ELK server

`nano /etc/nginx/install/filebeat/filebeat.yml`

Install the filebeat configuration file

`/etc/nginx/install/install-filebeat-config.sh`

Restart filebeat

`sudo systemctl restart filebeat`

### On your ELK server

Make a directory for this repository

`mkdir /var/git/ ; cd /var/git`

Clone this repository

`git clone https://github.com/zeropingheroes/lancache-elk.git /var/git/lancache-elk`

Install the lancache logstash filter

`ln -s /var/git/lancache-elk/logstash/conf.d/10-lancache-filter.conf /etc/logstash/conf.d`

Test the new configuration

`service logstash configtest`

Restart logstash

`service logstash restart`

Import Kibana visualisations and dashboards

`/var/git/lancache-elk/kibana/import.sh`

### Configure Kibana

After ELK has captured some log messages, log in to Kibana's web interface and complete these last steps:

#### Refresh Indexes
1. Open **Settings** and click **Indices**
2. Click the **filebeat-** index pattern
3. Click the amber **refresh field list** button

Do this when you see an unindexed field n the **Discover** view (amber warning triangle).

#### Format Field: Bytes
1. Scroll down to the **bytes** field and click the **edit** pencil
2. Change the **format** dropdown to **Bytes**
3. Change the **format pattern** to: *0,0.[0]b*
4. Click **Update Field**

#### Format Fields: range_* & slice_range_*
1. Scroll down to the **range_start** field and click the **edit** pencil
2. Change the **format** dropdown to **Bytes**
3. Change the **format pattern** to: *0,0.[000]b*
4. Click **Update Field**
5. Repeat this process for **range_end**, **slice_range_start** and **slice_range_end**

#### Format Field: Steam ID 3
1. Scroll down to the **steam_id_3** field and click the **edit** pencil
2. Change the **format** dropdown to **Url**
3. Change Url Template to: *http://steamid.co/player.php?input=U:1:{{value}}*
4. Change **Label Template** to *{{value}}*
5. Click **Update Field**

#### Format Field: Steam Depot ID
1. Scroll down to the **steam_depot_id** field and click the **edit** pencil
2. Change the **format** dropdown to **Url**
3. Change Url Template to: *http://steamdb.info/depot/{{value}}*
4. Change **Label Template** to *Depot {{value}}*
5. Click **Update Field**

## Contributing

Please submit pull requests for improving the configuration files here.

For example:

* Extracting additional fields from URIs
* Useful Kibana visualisations

Useful sites:

* [Logstash Grok Reference](https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html)
* [Logstash Grok Debugger](https://grokdebug.herokuapp.com/)
* [Grok Patterns](https://github.com/logstash-plugins/logstash-patterns-core/blob/master/patterns/grok-patterns)
* [Regex 101](https://regex101.com/)
