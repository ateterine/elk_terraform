#!/usr/bin/env bash

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade 

wget -qO - https://d3g5vo6xdbdb9a.cloudfront.net/GPG-KEY-opendistroforelasticsearch | sudo apt-key add -

sudo apt-get update
sudo apt-get install apt-transport-https
## This line is different for OSS verison of Kibana
echo "deb https://d3g5vo6xdbdb9a.cloudfront.net/apt stable main" | sudo tee -a   /etc/apt/sources.list.d/opendistroforelasticsearch.list

#Configure kibana

cat << EOF >/tmp/kibana.yml
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://${elasticsearch_host}:9200"]
kibana.index: ".kibana"
elasticsearch.requestTimeout: 300000
elasticsearch.shardTimeout: 0

elasticsearch.ssl.verificationMode: none

EOF

## This line is different for OSS verison of Kibana
sudo apt update
sudo apt install opendistroforelasticsearch-kibana=1.4.0

sudo mv /etc/kibana/kibana.yml /etc/kibana/my_kibana.yml.orig
sudo mv /tmp/kibana.yml /etc/kibana/kibana.yml
/usr/share/kibana/bin/kibana-plugin remove opendistro_security --allow-root

sudo -i service kibana start