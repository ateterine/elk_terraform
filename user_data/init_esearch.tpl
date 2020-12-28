#!/usr/bin/env bash

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
sudo apt-get install openjdk-8-jre -y
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get update
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update
sudo apt-get install elasticsearch=7.4.2
sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install discovery-ec2 -s --batch

cat << EOF >/tmp/elasticsearch.yml

path.data: ${elasticsearch_data_dir}
path.logs: /var/log/elasticsearch
discovery.type: single-node
cluster.name: ${elasticsearch_cluster}
network.host: _ec2:privateIpv4_
EOF

sudo mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.orig
sudo mv /tmp/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

sudo service elasticsearch restart
sudo update-rc.d elasticsearch defaults 95 10