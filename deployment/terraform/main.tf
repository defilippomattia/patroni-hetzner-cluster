terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

variable hcloud_token {
  sensitive = true
}

variable ssh_fingerprint {
  sensitive = true
}

provider "hcloud" {
  token = var.hcloud_token
}

data "hcloud_ssh_key" "phc_ssh_key" {
  fingerprint = var.ssh_fingerprint
}

resource "hcloud_network" "phc_network" {
  name     = "phc-network"
  ip_range = "10.10.120.0/24"
}

resource "hcloud_network_subnet" "phc_subnet" {
  network_id   = hcloud_network.phc_network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.10.120.0/24"
}

resource "hcloud_primary_ip" "node1_ip" {
    name          = "node1-ip"
    datacenter    = "nbg1-dc3"
    type          = "ipv4"
    assignee_type = "server"
    auto_delete   = true
    labels = {
        "created-by" : "terraform"
    }
}

resource "hcloud_primary_ip" "node2_ip" {
    name          = "node2-ip"
    datacenter    = "nbg1-dc3"
    type          = "ipv4"
    assignee_type = "server"
    auto_delete   = true
    labels = {
        "created-by" : "terraform"
    }
}

resource "hcloud_primary_ip" "node3_ip" {
    name          = "node3-ip"
    datacenter    = "nbg1-dc3"
    type          = "ipv4"
    assignee_type = "server"
    auto_delete   = true
    labels = {
        "created-by" : "terraform"
    }
}

resource "hcloud_firewall" "phc_firewall" {
  name = "phc-firewall"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  labels = {
    "created-by" : "terraform"
  }
}


resource "hcloud_server" "node1" {
  name        = "node1"
  image       = "rocky-9"
  server_type = "cx22"
  datacenter  = "nbg1-dc3"
  firewall_ids = [hcloud_firewall.phc_firewall.id]
  ssh_keys = [data.hcloud_ssh_key.phc_ssh_key.id]

    network {
        network_id = hcloud_network.phc_network.id
        ip = "10.10.120.11"
    }

  public_net {
    ipv4_enabled = true
    ipv4 = hcloud_primary_ip.node1_ip.id
    ipv6_enabled = false
  }

  user_data = <<-EOT
    #!/bin/bash
    useradd -m -G wheel mfilippo
    #should be ok, ssh key is used and user is forced to change password on first login
    echo "mfilippo:mfilippo" | chpasswd
    mkdir -p /home/mfilippo/.ssh
    cp /root/.ssh/authorized_keys /home/mfilippo/.ssh/
    chown -R mfilippo. /home/mfilippo/.ssh
    chmod 700 /home/mfilippo/.ssh
    chmod 600 /home/mfilippo/.ssh/authorized_keys
    rm -f /root/.ssh/authorized_keys

    chage -d 0 mfilippo

    sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart sshd
    EOT

  labels = {
    "created-by" : "terraform"
  }
}

resource "hcloud_server" "node2" {
  name        = "node2"
  image       = "rocky-9"
  server_type = "cx22"
  datacenter  = "nbg1-dc3"
  firewall_ids = [hcloud_firewall.phc_firewall.id]
  ssh_keys = [data.hcloud_ssh_key.phc_ssh_key.id]
 
    network {
        network_id = hcloud_network.phc_network.id
        ip = "10.10.120.12"
    }
  public_net {
    ipv4_enabled = true
    ipv4 = hcloud_primary_ip.node2_ip.id
    ipv6_enabled = false
  }

  user_data = <<-EOT
    #!/bin/bash
    useradd -m -G wheel mfilippo
    echo "mfilippo:mfilippo" | chpasswd
    mkdir -p /home/mfilippo/.ssh
    cp /root/.ssh/authorized_keys /home/mfilippo/.ssh/
    chown -R mfilippo. /home/mfilippo/.ssh
    chmod 700 /home/mfilippo/.ssh
    chmod 600 /home/mfilippo/.ssh/authorized_keys
    rm -f /root/.ssh/authorized_keys

    chage -d 0 mfilippo

    sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart sshd
    EOT

  labels = {
    "created-by" : "terraform"
  }
}

resource "hcloud_server" "node3" {
  name        = "node3"
  image       = "rocky-9"
  server_type = "cx22"
  datacenter  = "nbg1-dc3"
  firewall_ids = [hcloud_firewall.phc_firewall.id]
  ssh_keys = [data.hcloud_ssh_key.phc_ssh_key.id]
 
    network {
        network_id = hcloud_network.phc_network.id
        ip = "10.10.120.13"
    }
  public_net {
    ipv4_enabled = true
    ipv4 = hcloud_primary_ip.node3_ip.id
    ipv6_enabled = false
  }

  user_data = <<-EOT
    #!/bin/bash
    useradd -m -G wheel mfilippo
    echo "mfilippo:mfilippo" | chpasswd
    mkdir -p /home/mfilippo/.ssh
    cp /root/.ssh/authorized_keys /home/mfilippo/.ssh/
    chown -R mfilippo. /home/mfilippo/.ssh
    chmod 700 /home/mfilippo/.ssh
    chmod 600 /home/mfilippo/.ssh/authorized_keys
    rm -f /root/.ssh/authorized_keys

    chage -d 0 mfilippo

    sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart sshd
    EOT


  labels = {
    "created-by" : "terraform"
  }
}
