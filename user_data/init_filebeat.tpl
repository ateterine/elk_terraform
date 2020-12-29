#!/usr/bin/env bash

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade 

curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-oss-7.4.2-amd64.deb
sudo dpkg -i filebeat-oss-7.4.2-amd64.deb

cat << EOF >/tmp/filebeat.yml
#output.elasticsearch:
#  hosts: ["http://${elasticsearch_host}:9200"]

output.logstash:
    hosts: ["http://${logstash_host}:5044"]
    loadbalance: false
    ssl.enabled: false
filebeat.inputs:
- type: log
  paths:
    - /tmp/parkjockey.log
  scan_frequency: 10s

EOF

sudo mv /etc/filebeat/filebeat.yml /etc/filebeat/my_filebeat.yml.orig
sudo mv /tmp/filebeat.yml /etc/filebeat/filebeat.yml

sudo systemctl enable filebeat
sudo systemctl start filebeat