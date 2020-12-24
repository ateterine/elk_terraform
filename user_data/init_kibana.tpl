#!/usr/bin/env bash

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade 
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get update
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

#Configure kibana

cat << EOF >/tmp/kibana.yml
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://${elasticsearch_host}:9200"]
kibana.index: ".kibana"
elasticsearch.requestTimeout: 300000
elasticsearch.shardTimeout: 0
EOF

sudo apt-get update && sudo apt-get install kibana

sudo mv /etc/kibana/kibana.yml /etc/kibana/my_kibana.yml.orig
sudo mv /tmp/kibana.yml /etc/kibana/kibana.yml

sudo -i service kibana start