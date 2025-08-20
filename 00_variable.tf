# Déclaration des variables promox_api
variable "proxmox_api_token_id" {}
variable "proxmox_api_token_secret" {}
variable "proxmox_api_url" {}

#Déclaration des variables création des VMs
#Master
variable "name_cluster_master" {}
variable "name_node_master" {}
variable "interfaces_clusters_ip0_master" {} #cloud_init
variable "interfaces_clusters_ip1_master" {}
variable "id_master" {}
variable "ssh_host_master_port" {}

#Node 1
variable "name_cluster_node1" {}
variable "name_node_node1" {}
variable "interfaces_clusters_ip0_node1" {} #cloud_init
variable "interfaces_clusters_ip1_node1" {} #cloud_init
variable "id_node1" {}
variable "ssh_host_node1_port" {}

#Node 2
variable "name_cluster_node2" {}
variable "name_node_node2" {}
variable "interfaces_clusters_ip0_node2" {} #cloud_init
variable "interfaces_clusters_ip1_node2" {} #cloud_init
variable "id_node2" {}
variable "ssh_host_node2_port" {}

#Node 2
variable "name_cluster_node3" {}
variable "name_node_node3" {}
variable "interfaces_clusters_ip0_node3" {} #cloud_init
variable "interfaces_clusters_ip1_node3" {} #cloud_init
variable "id_node3" {}
variable "ssh_host_node3_port" {}



#Commun
variable "size_stockage_cluster" {}
variable "ssh_user" {}
variable "ssh_key" {}
variable "ssh_host_firewall" {}
variable "interfaces_vlan_tag1" {}
variable "interfaces_vlan_tag2" {}


#Déclaration des variables information pve
variable "node_name" {}
variable "clone_name" {}
variable "pool_k8s" {}
variable "storage_cluster_k8s" {}
variable "interfaces_clusters" {}


#Déclaration des variable pour le cloud-init
variable "ci_user" {}
variable "ci_mdp" {}
variable "ssh_key_pub" {}
variable "dns_name" {}
variable "dns_ip" {}


