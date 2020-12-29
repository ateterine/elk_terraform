output "elasticsearch_ip" {
  value = aws_instance.elasticsearch.private_ip
}

output "logstash_ip" {
  value = aws_instance.logstash.private_ip
}

output "kibana_url" {
  value = "http://${aws_instance.kibana.public_ip}:5601"
}

output "filebeat_url" {
  value = "http://${aws_instance.filebeat.public_ip}"
}

