#!/usr/bin/env bash

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade 

curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-oss-7.4.2-amd64.deb
sudo dpkg -i filebeat-oss-7.4.2-amd64.deb

cat << EOF >/tmp/filebeat.yml
#output.elasticsearch:
#  hosts: ["http://${elasticsearch_host}:9200"]

output.logstash:
  hosts: ["${logstash_host}:5044"]
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

cat << EOF >/tmp/parkjockey.log
[TRACE] 2020-12-22 19:42:06 [844] Event Bus - publish()
[TRACE] 2020-12-22 19:42:07 [834] Event Bus - publish()
[ERROR] 2020-12-22 19:42:11 [831] Lane Lane1 - onAccessAuthorized(3161: LP LCW*3022(TX)): AUTHORIZED from CLOUD
[ERROR] 2020-12-22 19:42:11 [831] Kiosk Kiosk1 - cancelRequest()
[ERROR] 2020-12-22 19:42:11 [831] MQTT - publish()
[ERROR] 2020-12-22 20:09:37 [830] Publisher - Failed to write event to beanstalk (0)
[ERROR] 2020-12-22 22:24:34 [840] Quercus LPR VehicleIdentifier21 - Empty image (3Car: 707)

EOF