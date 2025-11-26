# ----------------------------
# Déclaration des variables Proxmox API
# ----------------------------
proxmox_api_token_id     = "YOUR_PVE_TOKEN_ID"
proxmox_api_token_secret = "YOUR_PVE_TOKEN_SECRET"
proxmox_api_url          = "https://PVE_HOST:PORT/api2/json"

# ----------------------------
# Déclaration des variables création des VMs
# ----------------------------

# Master
name_cluster_master         = "MASTER_CLUSTER_NAME"
name_node_master            = "MASTER_NODE_NAME"
interfaces_clusters_ip0_master = "ip=MASTER_IP/24,gw=GATEWAY"
interfaces_clusters_ip1_master = "MASTER_IP"
id_master                   = "MASTER_VM_ID"
ssh_host_master_port        = "22"

# Node 1
name_cluster_node1          = "NODE1_CLUSTER_NAME"
name_node_node1             = "NODE1_NAME"
interfaces_clusters_ip0_node1 = "ip=NODE1_IP/24,gw=GATEWAY"
interfaces_clusters_ip1_node1 = "NODE1_IP"
id_node1                    = "NODE1_VM_ID"
ssh_host_node1_port         = "22"

# Node 2
name_cluster_node2          = "NODE2_CLUSTER_NAME"
name_node_node2             = "NODE2_NAME"
interfaces_clusters_ip0_node2 = "ip=NODE2_IP/24,gw=GATEWAY"
interfaces_clusters_ip1_node2 = "NODE2_IP"
id_node2                    = "NODE2_VM_ID"
ssh_host_node2_port         = "22"

# Node 3
name_cluster_node3          = "NODE3_CLUSTER_NAME"
name_node_node3             = "NODE3_NAME"
interfaces_clusters_ip0_node3 = "ip=NODE3_IP/24,gw=GATEWAY"
interfaces_clusters_ip1_node3 = "NODE3_IP"
id_node3                    = "NODE3_VM_ID"
ssh_host_node3_port         = "22"

# ----------------------------
# Variables communes
# ----------------------------
size_stockage_cluster       = "STORAGE_SIZE"
ssh_key                     = "~/.ssh/id_ed25519"
ssh_user                    = "SSH_USER"
ssh_host_firewall           = "FIREWALL_IP"

# ----------------------------
# Informations Proxmox VE
# ----------------------------
node_name                   = "PVE_NODE_NAME"
clone_name                  = "TEMPLATE_NAME"
pool_k8s                    = "K8S_POOL_NAME"
storage_cluster_k8s         = "STORAGE_NAME"
interfaces_clusters          = "NETWORK_INTERFACE"
interfaces_vlan_tag1         = "VLAN_TAG1"
interfaces_vlan_tag2         = "VLAN_TAG2"

# ----------------------------
# Variables Cloud-Init
# ----------------------------
ssh_key_pub                 = "~/.ssh/id_ed25519.pub"
ci_user                     = "CLOUD_INIT_USER"
ci_mdp                      = "CLOUD_INIT_PASSWORD"
dns_name                    = "DNS_NAME"
dns_ip                      = "DNS_IP"
