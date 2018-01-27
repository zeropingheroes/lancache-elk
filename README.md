# lancache-elk

Collect, process and visualise statistics from `zeropingheroes/lancache` with Elasticsearch, Logstash and Kibana

## Requirements

### ELK Server

* Ubuntu Server 16.04

### Lancache Server

* [`zeropingheroes/lancache`](https://github.com/zeropingheroes/lancache)
* [`zeropingheroes/lancache-filebeat`](https://github.com/zeropingheroes/lancache-filebeat)

## Installation

1. `git clone https://github.com/zeropingheroes/lancache-elk.git && cd lancache-elk`

2.  `./install.sh`

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
