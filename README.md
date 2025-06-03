# lancache-elk

Collect, process and visualise statistics from `zeropingheroes/lancache-bare-metal` with Elasticsearch, Logstash and Kibana

## Requirements

* Host running Ubuntu Server 24.04
* Separate host running [`zeropingheroes/lancache-bare-metal`](https://github.com/zeropingheroes/lancache)

## Set up Elasticsearch, Logstash & Kibana on ELK host

### Clone `zeropingheroes/lancache-elk` configs
```
git clone git@github.com/zeropingheroes/lancache-elk /opt
```

### Install Elasticsearch, Logstash & Kibana
```
sudo apt install apt-transport-https
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/9.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-9.x.list
sudo apt update
sudo apt install elasticsearch logstash kibana -y
```

### Enable systemd services
```
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch logstash kibana
```

### Set `elastic` superuser password
```
/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
```

### Start Elasticsearch
sudo systemctl start elasticsearch

### Check Elasticsearch is running
```
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:$ELASTIC_PASSWORD https://localhost:9200
```

### Set up reverse proxy for Kibana
```
sudo apt install apache2
sudo ln -s /opt/lancache-elk/etc/apache2/sites-available/kibana.conf /etc/apache2/sites-available/kibana.conf
sudo ln -s /etc/apache2/sites-available/kibana.conf /etc/apache2/sites-enabled/kibana.conf
echo "Listen 5602" | sudo tee -a /etc/apache2/ports.conf
sudo systemctl start apache2
```

### Generate and set Kibana encryption keys
```
/usr/share/kibana/bin/kibana-encryption-keys generate
```
Copy the config lines.

### Set Kibana's name and base URL
```
sudo nano /etc/kibana/kibana.yml
```
1. Set `server.publicBaseUrl` to your server's URL, for example `http://elk.example.com:5602`
2. Set `server.name` to your server's fully-qualified domain name, for example `elk.example.com`
3. Paste the generated key config from the previous step


### Create Kibana enrolment token
```
/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
```

### Start Kibana
```
sudo systemctl start kibana
sudo systemctl status kibana
```
1. Visit the URL provided by Kibana, changing the port to 5602
2. Enter the Elastic enrollment token
3. Click Configure Elastic
4. If you're prompted for a verification code, enter the code provided by the `status` command above
5. Log in with the username `elastic` and the password you set earlier

### Configure Elastic roles and users
1. Navigate to **Stack Management** > **Security** > **Users**
2. Create a user with privileges for viewing and editing dashboards
3. Navigate to **Stack Management** > **Security** > **Roles**
4. Create a `logstash_writer` role:
   1. Cluster privileges: `manage_index_templates`, `monitor` and `manage_ilm`
   2. Indices privileges: `write`, `create`, `create_index`, `manage` and `manage_ilm`
5. Navigate to **Stack Management** > **Security** > **Users**
6. Create a `logstash_internal` user with the `logstash_writer` role

### Create the Logstash keystore
```
/usr/share/logstash/bin/logstash-keystore create --path.settings /etc/logstash/
/usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash/ add ES_USER ES_PWD
```
* For `ES_USER` enter `logstash_internal`
* For `ES_PWD` enter the password you set above

### Provide Logstash with Elasticsearch certificate
```
sudo mkdir /etc/logstash/certs
sudo cp /etc/elasticsearch/certs/http_ca.crt /etc/logstash/certs/http_ca.crt
```

### Configure Logstash to use lancache pipelines
```
sudo tee -a /etc/logstash/pipelines.yml > /dev/null <<EOF
- pipeline.id: lancache
  path.config: "/opt/lancache-elk/etc/logstash/conf.d/*.conf"
EOF
```

### Set Logstash permissions
```
sudo usermod -a -G logstash YOUR_USERNAME
sudo chown -R logstash:logstash /usr/share/logstash /var/log/logstash/ /var/lib/logstash /etc/logstash /opt/lancache-elk/
sudo chmod -R g+w /usr/share/logstash /var/log/logstash/ /var/lib/logstash /etc/logstash /opt/lancache-elk/
```

### Test logstash config
```
/usr/share/logstash/bin/logstash --path.settings /etc/logstash/ --config.test_and_exit
```

### Set credentials for importing index templates, data views and dashboards
```
cd /opt/lancache-elk/
cp .env.example .env
nano .env
```

### Import index templates, data views and dashboards
```
/opt/lancache-elk/elastic-import-index-template.sh
/opt/lancache-elk/kibana-import-dashboard.sh
/opt/lancache-elk/kibana-import-data-view.sh
```

## Set up Filebeat on host running `zeropingheroes/lancache`

### Install Filebeat
```
sudo apt install apt-transport-https
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/9.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-9.x.list
sudo apt update
sudo apt install filebeat -y
```

### Clone `zeropingheroes/lancache-elk` configs
```
git clone git@github.com/zeropingheroes/lancache-elk /opt
```

### Configure Filebeat to use `zeropingheroes/lancache` config
```
sudo mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.default
sudo ln -s /opt/lancache-elk/etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml
```

### Configure Filebeat to send to your ELK host
```
sudo nano /opt/lancache-elk/etc/filebeat/filebeat.yml
```
Change `example.com` to your logstash server's fully-qualified domain name.

### Enable and start Filebeat
```
sudo systemctl daemon-reload
sudo systemctl enable filebeat
sudo systemctl start filebeat
```

## Troubleshoot ELK

### Debug Logstash config
```
cd /opt/lancache-elk/etc/logstash/conf.d/
mv 98-output-debug.conf.disabled 98-output-debug.conf
mv 99-output-elastic.conf 99-output-elastic.conf.disabled
sudo systemctl stop logstash
/usr/share/logstash/bin/logstash --path.settings /etc/logstash/ --config.reload.automatic
```

### Revert Logstash debugging
```
mv 98-output-debug.conf 98-output-debug.conf.disabled
mv 99-output-elastic.conf.disabled 99-output-elastic.conf
```

## Troubleshoot Filebeat

### Check Filebeat logs
```
sudo journalctl -u filebeat
```

## Field reference

| Elastic Field                 | Type       | Elastic Data Type | HTTP Access | HTTP Error | Stream Access | Stream Error |
| ----------------------------- | ---------- | ----------------- | ----------- | ---------- | ------------- | ------------ |
| @timestamp                    | Base ECS   | date              | ✅         | ✅         | ✅           | ✅           |
| client.bytes                  | Base ECS   | long              | ✅         | ❌         | ✅           | ✅           |
| client.ip                     | Base ECS   | ip                | ✅         | ✅         | ✅           | ✅           |
| error.message                 | Base ECS   | match_only_text   | ❌         | ✅         | ❌           | ✅           |
| http.request.method           | Base ECS   | keyword           | ✅         | ✅         | ❌           | ❌           |
| http.request.ranges.end       | Base ECS   | long              | ✅         | ❌         | ❌           | ❌           |
| http.request.ranges.original  | Base ECS   | keyword           | ✅         | ❌         | ❌           | ❌           |
| http.request.ranges.start     | Base ECS   | long              | ✅         | ❌         | ❌           | ❌           |
| http.request.referrer         | Base ECS   | keyword           | ✅         | ✅         | ❌           | ❌           |
| http.response.body.bytes      | Base ECS   | long              | ✅         | ❌         | ❌           | ❌           |
| http.response.status_code     | Base ECS   | long              | ✅         | ✅         | ✅           | ❌           |
| http.version                  | Base ECS   | keyword           | ✅         | ✅         | ❌           | ❌           |
| log.level                     | Base ECS   | keyword           | ✅         | ✅         | ✅           | ✅           |
| nginx.bytes                   | Base ECS   | long              | ❌         | ❌         | ❌           | ✅           |
| nginx.connection_id           | Custom ECS | long              | ❌         | ✅         | ❌           | ✅           |
| nginx.session_duration        | Custom ECS | float             | ✅         | ❌         | ✅           | ❌           |
| nginx.slice.range.end         | Custom ECS | long              | ✅         | ❌         | ❌           | ❌           |
| nginx.slice.range.start       | Custom ECS | long              | ✅         | ❌         | ❌           | ❌           |
| process.pid                   | Base ECS   | long              | ❌         | ✅         | ❌           | ✅           |
| process.thread.id             | Base ECS   | long              | ❌         | ❌         | ❌           | ❌           |
| server.bytes                  | Base ECS   | long              | ✅         | ❌         | ✅           | ✅           |
| steam.depot.id                | Custom ECS | keyword           | ✅         | ✅         | ❌           | ❌           |
| steam.depot.chunk.id          | Custom ECS | keyword           | ✅         | ✅         | ❌           | ❌           |
| steam.depot.manifest.id       | Custom ECS | keyword           | ✅         | ✅         | ❌           | ❌           |
| steam.depot.manifest.segment1 | Custom ECS | keyword           | ✅         | ✅         | ❌           | ❌           |
| steam.depot.manifest.segment2 | Custom ECS | keyword           | ✅         | ✅         | ❌           | ❌           |
| upstream.address              | Base ECS   | keyword           | ✅         | ✅         | ✅           | ✅           |
| upstream.bytes                | Base ECS   | long              | ✅         | ❌         | ❌           | ✅           |
| upstream.cache_status         | Custom ECS | keyword           | ✅         | ❌         | ❌           | ❌           |
| upstream.label                | Custom ECS | keyword           | ✅         | ✅         | ✅           | ✅           |
| upstream.response.status_code | Custom ECS | long              | ✅         | ❌         | ❌           | ❌           |
| upstream.response.time        | Custom ECS | float             | ✅         | ❌         | ❌           | ❌           |
| upstream.url                  | Custom ECS | keyword           | ❌         | ✅         | ❌           | ❌           |
| url.path                      | Base ECS   | wildcard          | ✅         | ✅         | ❌           | ❌           |
| url.query                     | Base ECS   | keyword           | ✅         | ✅         | ❌           | ❌           |
| user_agent.original           | Base ECS   | match_only_text   | ✅         | ❌         | ❌           | ❌           |

## References and further reading
* https://www.elastic.co/docs/deploy-manage/deploy/self-managed/install-elasticsearch-with-debian-package 
* https://www.elastic.co/docs/deploy-manage/deploy/self-managed/install-kibana-with-debian-package
* https://www.elastic.co/docs/reference/logstash/installing-logstash
* https://www.elastic.co/docs/reference/logstash/secure-connection#es-security-onprem
* https://www.elastic.co/docs/reference/logstash/keystore
* https://www.elastic.co/docs/reference/beats/filebeat/configuration-filebeat-options
* https://www.elastic.co/docs/reference/beats/filebeat/filebeat-input-filestream
* https://www.elastic.co/docs/reference/beats/filebeat/exported-fields-beat-common
* https://www.elastic.co/docs/reference/beats/filebeat/exported-fields-log
* https://www.elastic.co/docs/reference/beats/filebeat/logstash-output
* https://www.elastic.co/docs/reference/beats/filebeat/configuration-general-options#libbeat-configuration-fields
* https://regex-generator.olafneumann.org
* https://github.com/logstash-plugins/logstash-patterns-core/blob/main/patterns/ecs-v1/grok-patterns
* https://github.com/zeropingheroes/lancache-bare-metal/blob/main/access-log-formats/http/detailed.conf
* https://www.elastic.co/docs/reference/ecs/ecs-http
* https://www.elastic.co/docs/reference/security/fields-and-object-schemas/siem-field-reference
* https://www.elastic.co/docs/reference/observability/fields-and-object-schemas
* https://www.elastic.co/docs/reference/logstash/plugins/plugins-filters-grok
* https://www.elastic.co/docs/reference/ecs/ecs-getting-started
* https://www.elastic.co/docs/reference/ecs/ecs-guidelines
* https://www.elastic.co/blog/do-you-grok-grok

## Contributing

Submit pull requests that for example:

* Extract additional fields from URIs
* Add Kibana visualisations

Modify index templates, dashboards and data views in Kibana, and use the export scripts to add them to the repository.
