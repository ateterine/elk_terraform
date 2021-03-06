provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "iam" {
  source = "./iam"
}

module "network" {
  source = "./network"
}

module "security" {
  source           = "./security"
  vpc_id           = module.network.elk_vpc_id
  private_vpc_cidr = module.network.elk_private_subnet_cidr
  public_vpc_cidr  = module.network.elk_public_subnet_cidr
}

data "template_file" "init_elasticsearch" {
  template = file("./user_data/init_esearch_oss.tpl")

  vars = {
    elasticsearch_cluster  = var.elasticsearch_cluster
    elasticsearch_data_dir = var.elasticsearch_data_dir
  }
}

resource "aws_instance" "elasticsearch" {
  ami                  = var.aws_amis[var.aws_region]
  instance_type        = var.elk_instance_type
  key_name             = var.aws_key_name
  security_groups      = [module.security.elasticsearch_sc_id]
  subnet_id            = module.network.elk_private_subnet_id
  iam_instance_profile = module.iam.es_iam_id

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "20"
  }

  user_data = data.template_file.init_elasticsearch.rendered

  tags = merge(map("Name", "Elasticsearch instance"), map("tostop", "true"))

}

data "template_file" "init_logstash" {
  template = file("./user_data/init_logstash_oss.tpl")

  vars = {
    elasticsearch_host = aws_instance.elasticsearch.private_ip
  }
}

resource "aws_instance" "logstash" {
  ami             = var.aws_amis[var.aws_region]
  instance_type   = var.elk_instance_type
  key_name        = var.aws_key_name
  security_groups = [module.security.esearch_sc_id]
  subnet_id       = module.network.elk_private_subnet_id

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "20"
  }

  user_data = data.template_file.init_logstash.rendered

  tags = merge(map("Name", "Logstash instance"), map("tostop", "true"))
}

data "template_file" "init_kibana" {
  template = file("./user_data/init_kibana_oss.tpl")

  vars = {
    elasticsearch_host = aws_instance.elasticsearch.private_ip
  }
}

resource "aws_instance" "kibana" {
  ami             = var.aws_amis[var.aws_region]
  instance_type   = var.elk_instance_type
  key_name        = var.aws_key_name
  security_groups = [module.security.elk_sc_id]
  subnet_id       = module.network.elk_public_subnet_id

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "10"
  }

  user_data = data.template_file.init_kibana.rendered

  tags = merge(map("Name", "Kibana instance"), map("tostop", "true"))

}

data "template_file" "init_filebeat" {
  template = file("./user_data/init_filebeat.tpl")

  vars = {
    elasticsearch_host = aws_instance.elasticsearch.private_ip
    logstash_host      = aws_instance.logstash.private_ip
  }
}

resource "aws_instance" "filebeat" {
  ami             = var.aws_amis[var.aws_region]
  instance_type   = var.elk_instance_type
  key_name        = var.aws_key_name
  security_groups = [module.security.elk_sc_id]
  subnet_id       = module.network.elk_public_subnet_id

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "10"
  }

  user_data = data.template_file.init_filebeat.rendered

  tags = merge(map("Name", "Filebeat instance"), map("tostop", "true"))

}
