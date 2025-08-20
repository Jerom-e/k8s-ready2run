resource "proxmox_vm_qemu" "master" {
  name       = var.name_cluster_master
  agent      = 1
  target_node = var.name_node_master  # Spécifiez le nom de votre nœud Proxmox ici
  clone      =  var.clone_name
  scsihw     = "virtio-scsi-pci"
  full_clone   = true
  #system
  vmid       = var.id_master
  cores      = 16
  memory     = 16384
  cpu        = "host"
  os_type    = "cloud-init"
  tags       = "master"
  #boot option
  bootdisk   = "scsi0"
  pool = var.pool_k8s
  # Configuration du disque
    #disk
    disks {
      scsi {
      scsi0 {
       disk {
     size = var.size_stockage_cluster
     storage = var.storage_cluster_k8s
     format  = "raw"
            }
       } 
      }
      ide {
        ide2 {
          cloudinit {
            storage = var.storage_cluster_k8s
          }
        }
      }
    
    }

  # Configuration du réseau

  network {
    model            = "virtio"
    bridge           = var.interfaces_clusters
    #tag              = var.interfaces_vlan_tag1 
    }

  # network {
  #   model            = "virtio"
  #   bridge           = var.interfaces_clusters
  #   tag              = var.interfaces_vlan_tag2 
  #   }


# Utiliser Cloud-Init pour configurer l'IP et le nom d'hôte unique
  ciuser      = var.ci_user       # Utilisateur configuré via Cloud-Init
  cipassword  = var.ci_mdp      # Mot de passe pour l'utilisateur
  sshkeys     = file(var.ssh_key_pub)  # Ajouter une clé SSH pour accéder aux VMs (optionnel)
  ipconfig0 = var.interfaces_clusters_ip0_master  # Remplacez par votre passerelle réseau
  #ipconfig1 = var.interfaces_clusters_ip1_master
  searchdomain = var.dns_name
  nameserver = var.dns_ip
}

