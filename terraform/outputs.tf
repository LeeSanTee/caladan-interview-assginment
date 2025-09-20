########################
#### simple_app
########################
output "instance_id_simple_app" {
  value = module.simple_app.instance_id
}

output "private_dns_simple_app" {
  value = module.simple_app.private_dns
}

output "subnet_id_simple_app" {
  value = module.simple_app.subnet_id
}

output "ami_id_simple_app" {
  value = module.simple_app.ami_id
}

output "public_dns_simple_app" {
  value = module.simple_app.public_dns
}

output "public_ip_simple_app" {
  value = module.simple_app.public_ip
}
########################
#### metrics_exporter
########################
output "instance_id_metrics_exporter" {
  value = module.metrics_exporter.instance_id
}

output "private_dns_metrics_exporter" {
  value = module.metrics_exporter.private_dns
}

output "subnet_id_metrics_exporter" {
  value = module.metrics_exporter.subnet_id
}

output "ami_id_metrics_exporter" {
  value = module.metrics_exporter.ami_id
}

output "public_dns_metrics_exporter" {
  value = module.metrics_exporter.public_dns
}

output "public_ip_metrics_exporter" {
  value = module.metrics_exporter.public_ip
}
