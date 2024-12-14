
# Introduction

Deploy a 3 nodes POC Postgres cluster with Patroni and Etcd on Hetzner Cloud.

I'm not following best practices here (VMs on public internet, some passwords on the repo, etc) but this is just a POC.

# Deployment 

## Terraform 

```
touch ./deployment/terraform/variables.tfvars
hcloud_token = "your-hetzner-api-token"
ssh_fingerprint = "your-ssh-fingerprint"

cd ./deployment/terraform
terraform init 
terraform plan -var-file="variables.tfvars"
terraform apply -var-file="variables.tfvars"
terraform destroy -var-file="variables.tfvars"
```

## Ansible 

```
touch ./deployment/ansible/hosts.ini
[phc-cluster]
node1 ansible_host=public_ip1 private_ip=private_ip1
node2 ansible_host=public_ip2 private_ip=private_ip2
node3 ansible_host=public_ip3 private_ip=private_ip3

[phc-cluster:vars]
ansible_ssh_private_key_file=/path/to/your/private/key
ansible_user=mfilippo

cd ./deployment/ansible
ansible-playbook -i hosts.ini 000_initial_config.yml -e "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'" --ask-become-pass
ansible-playbook -i hosts.ini 001_postgres.yml -e "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'" -l node1,node2 --ask-become-pass
ansible-playbook -i hosts.ini 002_etcd.yml -e "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'" --ask-become-pass
ansible-playbook -i hosts.ini 003_patroni/003_patroni.yml -e "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'" --ask-become-pass -l node1,node2

```
# Test and document

- [] tests from https://patroni.readthedocs.io/en/latest/README.html
- [] upgrade patroni and etcd (maintanance mode...)
- [] restart patroni without putting the cluster in maintanance mode