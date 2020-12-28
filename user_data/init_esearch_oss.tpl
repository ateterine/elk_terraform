#!/usr/bin/env bash

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt update

sudo apt install openjdk-11-jdk -y

wget -qO - https://d3g5vo6xdbdb9a.cloudfront.net/GPG-KEY-opendistroforelasticsearch | sudo apt-key add -

sudo apt-get update
sudo apt-get install apt-transport-https
## This line is different for OSS verison of ES
echo "deb https://d3g5vo6xdbdb9a.cloudfront.net/apt stable main" | sudo tee -a   /etc/apt/sources.list.d/opendistroforelasticsearch.list

sudo apt-get update
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.4.2-amd64.deb
## This line is different for OSS verison of ES
sudo dpkg -i elasticsearch-oss-7.4.2-amd64.deb

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

# Installing OpenDistro Plugins
sudo apt update
sudo apt install opendistro-alerting=1.4.0.0-1
sudo apt install opendistro-job-scheduler=1.4.0.0-1

sudo service elasticsearch restart
sudo update-rc.d elasticsearch defaults 95 10