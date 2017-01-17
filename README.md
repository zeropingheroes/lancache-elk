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

`ln -s /var/git/logstash/conf.d/10-lancache-filter.conf /etc/logstash/conf.d`

Test the new configuration

`service logstash configtest`

Restart logstash

`service logstash restart`

