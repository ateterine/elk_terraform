#!/usr/bin/env bash

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt update

sudo apt install openjdk-11-jdk -y

##############################
#wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get update
sudo apt-get install apt-transport-https
#echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
curl -L -O https://artifacts.elastic.co/downloads/logstash/logstash-oss-7.4.2.deb

sudo dpkg -i logstash-oss-7.4.2.deb


#sudo update-rc.d logstash defaults 97 8
sudo service logstash start

# Configure the logstash service

cat << EOF >/tmp/logstash.conf
input {
    heartbeat {
        interval => 10
        type => "heartbeat"
        message => "epoch"
    }
}
output {
    stdout {
        codec => rubydebug
    }
    elasticsearch {
        hosts => ["${elasticsearch_host}:9200"] 
    }
}


EOF

sudo mv /tmp/logstash.conf /etc/logstash/conf.d/7-syslog.conf
sudo service logstash restart