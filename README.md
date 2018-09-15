# lancache-elk

Collect, process and visualise statistics from `zeropingheroes/lancache` with Elasticsearch, Logstash and Kibana

## Screenshots

These screenshots are taken from a 100 person event, with the cache pre-loaded using [zeropingheroes/lancache-autofill](https://github.com/zeropingheroes/lancache-autofill)

### Dashboard - General
![Dashboard - General](https://i.imgur.com/65tnTTe.png)

### Dashboard - Steam
![Dashboard - General](https://i.imgur.com/dZT0LOo.png)

### Dashboard - Errors
![Dashboard - General](https://i.imgur.com/JitcGTH.png)

## Requirements

### ELK Server

* Ubuntu Server 16.04

### Lancache Server

* [`zeropingheroes/lancache`](https://github.com/zeropingheroes/lancache)
* [`zeropingheroes/lancache-filebeat`](https://github.com/zeropingheroes/lancache-filebeat)

_`lancache-elk` cannot be run on the same host as `lancache` as both use port 80._

## Installation

1. `git clone https://github.com/zeropingheroes/lancache-elk.git && cd lancache-elk`

2. `cp .env.example .env`

3. `nano .env`

4.  `./install.sh`

5. Log into the Kibana web interface and go to **Management** > **Saved Objects**

6. Import `lancache-elk/configs/kibana/export.json` choosing "logstash-*" in the dropdown under "New index pattern"

7. Repeat step 6 a second time - not sure exactly why this is necessary...

# Available Dashboards

* **Overall** - Global cumulative data about the cache
* **General** - Visualisations that apply to any upstream
* **Steam** - See which depots are cached, and which Steam users are downloading games

# Known Issues

## Incorrect Cache Hit/Miss Stats for Blizzard and Origin

Because we use `slice` for these upstreams, Nginx reports a cache hit for almost all requests from clients, as the single client request has spawned one or more subrequests which fill the cache.
This also means that our statistics for how much data has been added to the cache is incorrect too. If you have a workaround for this behaviour, please submit a pull request. 

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
