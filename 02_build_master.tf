
# Utiliser un null_resource avec for_each pour chaque serveur
resource "null_resource" "create_master" {
  # Connexion SSH pour exécuter les commandes à distance
  connection {
    type        = "ssh"
    host        = var.interfaces_clusters_ip1_master
    user        = var.ssh_user
    port        = var.ssh_host_master_port
    private_key = file(var.ssh_key)  # Chemin vers la clé privée SSH
  }
  

  provisioner "file" {
         source =      "sh/create_master.sh"
         destination = "/tmp/create_master.sh"
         }

  provisioner "file" {
	 source	=	"conf/k8s.conf"
	 destination = "/tmp/k8s.conf"
    }

 
  # Provisioner pour exécuter des commandes à distance
  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf *",
      "cp /tmp/create_master.sh .",
      "chmod +x create_master.sh",
      "./create_master.sh"
      
      ]
  }
depends_on = [proxmox_vm_qemu.node3]
}

