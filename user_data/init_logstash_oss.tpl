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
    beats {
        port => 5044
        client_inactivity_timeout => 120
    }
}
filter {
        # Processing of edge servers
        grok {
                match => {"message" => "\[(?<level_raw>[^\]]*)] %%{TIMESTAMP_ISO8601:log_time} \[%%{NUMBER:process_id}\] (?<module>[^-]*) - %%{GREEDYDATA:log_message}"}
                overwrite => [ "message" ]
        }
        if [level_raw] == "ERROR" {
                mutate {
                        add_field => { "level" => "error" }
                }
                translate {
                    field => "[log_message]"
                    destination => "[error_type]"
                    exact => true
                    regex => true
                    dictionary_path => "/etc/logstash/conf.d/edge_dictionary.yaml"
                }
        }
        date {
                match => ["log_time", "YYYY-MM-dd HH:mm:ss"]
                target => "@timestamp"
            }
}
output {
  if [@metadata][pipeline] {
    elasticsearch {
      hosts => "http://${elasticsearch_host}:9200"
      manage_template => false
      index => "%%{[@metadata][beat]}-%%{[@metadata][version]}-%%{+YYYY.MM.dd}"
      pipeline => "%%{[@metadata][pipeline]}" 
    }
  } else {
    elasticsearch {
      hosts => "http://${elasticsearch_host}:9200"
      manage_template => false
      index => "%%{[@metadata][beat]}-%%{[@metadata][version]}-%%{+YYYY.MM.dd}"
    }
  }
}

EOF

# Configure Pipelines
cat << EOF >/tmp/pipelines.yml
- pipeline.id: shipping
  path.config: "/etc/logstash/conf.d/7-syslog.conf"
EOF

cat << EOF >/tmp/edge_dictionary.yaml
###### Matching Edge Software
"Error processing event" : "Edge Software"
"Unable to open Ksock" : "Edge Software"
"Unable to bind to Ksock" : "Edge Software"
"Kbus message poll failed with error" : "Edge Software"
"Kbus message empty" : "Edge Software"
"Exception on Request" : "Edge Software"
"Unable to initialize SmartLPR - please check logs" : "Edge Software"
"Failed to send event" : "Edge Software"
"Failed to switch to event queue" : "Edge Software"
"Failed to write event to beanstalk" : "Edge Software"
"Beanstalk error" : "Edge Software"
"Failed to send stats" : "Edge Software"
"Failed to switch to stats queue" : "Edge Software"
"Failed to write stats to beanstalk" : "Edge Software"

##### Matching LPR
"Error parsing CitySync XML message" : "LPR"
"Missing anprEvent element" : "LPR"
"Missing lane element" : "LPR"
"Error JSON message" : "LPR"
"Empty image" : "LPR"

##### Matching WebRelay
"Error processing event" : "WebRelay"
"Error opening barrier" : "WebRelay"
"Error closing barrier" : "WebRelay"

##### Matching Intercom
"Error playing audio file" : "Intercom"
"Error placing call" : "Intercom"
"Error placing default call" : "Intercom"
"Error terminating call" : "Intercom"
"Error parsing Cyberdata XML" : "Intercom"

##### Matching Display Sign
"Unable to connect to host" : "Display Sign"
"Socket error" : "Display Sign"
"Error setting signage to" : "Display Sign"

##### Matching MQTT client
"Failed to create client" : "MQTT client"
"Connect() failed, return code" : "MQTT client"
"Client failed to connect to broker" : "MQTT client"
"Disconnect() failed, return code" : "MQTT client"
"Failed to connect to broker, return code" : "MQTT client"
"Message with token" : "MQTT client"

##### Matching Edge - Cloud communication
"Error publishing event" : "Edge - Cloud communication"
"Error publishing stats" : "Edge - Cloud communication"
"Error getting authorization" : "Edge - Cloud communication"
"Missing session ID and location occupancy data" : "Edge - Cloud communication"
"Unknown access denial reason" : "Edge - Cloud communication"
"Unexpected response code" : "Edge - Cloud communication"
"Error getting location data" : "Edge - Cloud communication"
"Missing location data" : "Edge - Cloud communication"
"Unexpected response code" : "Edge - Cloud communication"

##### Macthing Overview Camera
"Error getting current image" : "Overview camera"
EOF

sudo /usr/share/logstash/bin/logstash-plugin install logstash-filter-grok
sudo /usr/share/logstash/bin/logstash-plugin install logstash-filter-mutate
sudo /usr/share/logstash/bin/logstash-plugin install logstash-filter-date
sudo /usr/share/logstash/bin/logstash-plugin install logstash-filter-translate

sudo mv /etc/logstash/pipelines.yml /etc/logstash/pipelines.yml.orig
sudo mv /tmp/edge_dictionary.yaml /etc/logstash/conf.d/edge_dictionary.yaml

sudo mv /tmp/pipelines.yml /etc/logstash/pipelines.yml
sudo mv /tmp/logstash.conf /etc/logstash/conf.d/7-syslog.conf
sudo service logstash restart