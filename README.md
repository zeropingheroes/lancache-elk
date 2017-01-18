# lancache-elk
Collect, process and visualise statistics from `zeropingheroes/lancache` with ELK

## Requirements

* Ubuntu Server 16.04
* [Installation of ELK](https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-ubuntu-14-04)
* `zeropingheroes/lancache` running on another server

## Usage

### On your ELK server:

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

## Contributing

Please submit pull requests for improving the configuration files here.

For example:

* Extracting additional fields from URIs
* Useful Kibana visualisations

Useful sites:

* [Logstash Grok Reference](https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html)
* [Logstash Grok Debugger](https://grokdebug.herokuapp.com/)
* [Regex 101](https://regex101.com/)