# lancache-elk

Collect, process and visualise statistics from `zeropingheroes/lancache` with Elasticsearch, Logstash and Kibana

## Requirements

### ELK Server

* Ubuntu Server 16.04

### Lancache Server

* [`zeropingheroes/lancache`](https://github.com/zeropingheroes/lancache)
* [`zeropingheroes/lancache-filebeat`](https://github.com/zeropingheroes/lancache-filebeat)

## Installation

1. `git clone https://github.com/zeropingheroes/lancache-installer.git && cd lancache-installer`

2.  `./install.sh`

### Configure Kibana

After ELK has captured some log messages, visit Kibana's web interface and complete these last steps:

#### Refresh Indexes

1. Open **Settings** and click **Indices**
2. Click the **filebeat-** index pattern
3. Click the amber **refresh field list** button

Do this when you see an unindexed field in the **Discover** view (amber warning triangle).

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

#### Format Field: Steam ID 3

1. Scroll down to the **steam_id_3** field and click the **edit** pencil
2. Change the **format** dropdown to **Url**
3. Change **Url Template** to: *http://steamid.co/player.php?input=U:1:{{value}}*
4. Change **Label Template** to *{{value}}*
5. Click **Update Field**

#### Format Field: Steam Depot ID

1. Scroll down to the **steam_depot_id** field and click the **edit** pencil
2. Change the **format** dropdown to **Url**
3. Change **Url Template** to: *http://steamdb.info/depot/{{value}}*
4. Change **Label Template** to *Depot {{value}}*
5. Click **Update Field**

That's it - you're done! Now you can navigate to **Dashboards** and choose a dashboard to see what's going on with your lancache.

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
