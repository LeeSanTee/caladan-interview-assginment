
module "simple_app" {
  source = "./modules/compute"
  
  aws_profile      = "np-workload"
  aws_region       = "ap-southeast-1"
  team_name        = "devops"
  environment_name = "dev"
  project_name     = "simple-app"
  ami_prefix       = "packer-simple-app"
  instance_type    = "t3.micro"
  ssh_key_name     = "leewookanh-test"
  vpc_name         = "non-prod-workload"
  subnet_prefix    = "non-prod-workload-private-"
  enable_eip       = false
}


module "metrics_exporter" {
  source = "./modules/compute"
  depends_on = [ module.simple_app ]

  aws_profile      = "np-workload"
  aws_region       = "ap-southeast-1"
  team_name        = "devops"
  environment_name = "dev"
  project_name     = "metrics-exporter"
  ami_prefix       = "packer-metrics-exporter"
  instance_type    = "t3.micro"
  ssh_key_name     = "leewookanh-test"
  vpc_name         = "non-prod-workload"
  subnet_prefix    = "non-prod-workload-private-"
  enable_eip       = false
  user_data        = <<-EOT
    #!/bin/bash
    echo "SIMPLE_APP_URL=http://${module.simple_app.private_dns}:8080" | sudo tee -a /etc/app.vars
    systemctl restart golang-app
  EOT
}

