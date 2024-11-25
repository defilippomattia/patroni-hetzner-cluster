
# Deployment 

## Terraform 

```
touch ./deployments/terraform/variables.tfvars
hcloud_token = "your-hetzner-api-token"

cd ./deployments/terraform
terraform plan -var-file="variables.tfvars"
terraform apply -var-file="variables.tfvars"
terraform destroy -var-file="variables.tfvars"

```

## Ansible 

(manual on each node) 
```
useradd -m -G wheel mfilippo && passwd mfilippo
mkdir -p /home/mfilippo/.ssh && cp /root/.ssh/authorized_keys /home/mfilippo/.ssh/
chown -R mfilippo. /home/mfilippo/.ssh && chmod 700 /home/mfilippo/.ssh && chmod 600 /home/mfilippo/.ssh/authorized_keys
rm -f /root/.ssh/authorized_keys
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && systemctl restart sshd
```



Patroni and etcd on each node, Postgres on node1 and node2
```
touch ./deployments/ansible/hosts.ini
[phc-cluster]
node1 ansible_host=ip1
node2 ansible_host=ip2 
node3 ansible_host=ip3

[phc-cluster:vars]
ansible_ssh_private_key_file=/path/to/your/private/key
ansible_user=mfilippo


ansible-playbook -i hosts.ini 000_initial_config.yml -e "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'" --ask-become-pass
ansible-playbook -i hosts.ini 001_patroni.yml -e "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'" --ask-become-pass
ansible-playbook -i hosts.ini 002_postgres.yml -e "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'" -l node1,node2 --ask-become-pass

```
# Test and document

- [] tests from https://patroni.readthedocs.io/en/latest/README.html
- [] upgrade patroni and etcd (maintanance mode...)
- [] restart patroni without putting the cluster in maintanance mode