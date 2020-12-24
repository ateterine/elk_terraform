variable "aws_region" {
  description = "AWS regione where launch servers"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "aws profile"
  default     = "default"
}

variable "aws_amis" {
  default = {
    eu-west-1 = "ami-035966e8adab4aaad"
    us-west-2 = "ami-0d1cd67c26f5fca19"
    us-east-1 = "ami-00ddb0e5626798373"
  }
}

variable "elk_instance_type" {
  default = "m4.large"
}


variable "aws_key_name" {
  description = "Name of the AWS key pair"
  default     = "ateterine"

}

variable "elasticsearch_data_dir" {
  default = "/var/lib/elasticsearch"
}

variable "elasticsearch_cluster" {
  description = "Name of the elasticsearch cluster"
  default     = "elk_cluster"
}

