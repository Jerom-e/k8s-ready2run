# k8s-ready2run

**Automated Kubernetes Cluster Deployment on AlmaLinux 9**  
Provisioning of VMs via Terraform, installation of containerd, Kubernetes master, and worker nodes with full automation.

---

## ⭐ Objectif

Ce projet facilite la création d’un **cluster Kubernetes complet** sur AlmaLinux 9 :

- Provisioning des machines via **Terraform**  
- Installation et configuration de **containerd**  
- Déploiement du **master** et des **nœuds workers**  
- Application de la configuration réseau et sécurité via **scripts Bash**  
- Gestion automatisée des tokens Kubernetes et Cloud-init pour les VM  
- Simplifie le déploiement pour les équipes DevOps et IaC

---

## Structure du dépôt

```text
k8s-ready2run/
├── 00_provider.tf             # Configuration du provider Proxmox pour Terraform
├── 00_variable.tf             # Déclaration des variables Terraform
├── 01_create_master.tf        # Création du master Kubernetes
├── 01.1_create_node1.tf       # Création Node1
├── 01.2_create_node2.tf       # Création Node2
├── 01.2_create_node3.tf       # Création Node3
├── 02_build_master.tf         # Installation et configuration du master
├── 02.1_share_token.tf        # Partage du token pour join des nodes
├── 02.2_build_node1.tf        # Installation Node1
├── 02.3_build_node2.tf        # Installation Node2
├── 02.3_build_node3.tf        # Installation Node3
├── conf/                      # Configuration des services
│   └── k8s.conf               # Paramètres spécifiques Kubernetes
├── sh/                        # Scripts d’automatisation
│   ├── create_master.sh       # Script Bash pour master
│   └── create_node.sh         # Script Bash pour les nodes
└── terraform.tfvars           # Variables personnalisées pour Terraform
```

Mise en route

1. Cloner le dépôt
 ```bash
git clone git@github.com:Jerom-e/k8s-ready2run.git
cd k8s-ready2run
```
2. Créer votre fichier de configuration

Éditez terraform.tfvars avec vos valeurs pour Proxmox API, IPs, SSH, VM IDs, etc.

3. Initialiser Terraform

```bash
terraform init
```



4. Vérifier la configuration

```bash
terraform plan
```

5. Déployer le cluster

```bash
terraform apply
```

```text
| Atout                       | Description                                           |
| --------------------------- | ----------------------------------------------------- |
| **Automatisation complète** | Du provisionnement à la configuration Kubernetes      |
| **Sécurité**                | Scripts pour SSH, Cloud-init et configurations réseau |
| **Modularité**              | Chaque VM a ses propres fichiers Terraform et scripts |
| **Lisibilité**              | Variables et scripts clairement nommés                |
| **Extensible**              | Ajout facile de nouveaux nœuds ou services            |
```


Bonnes pratiques

Ne jamais pousser vos secrets (terraform.tfvars) dans GitHub. Utilisez terraform.tfvars.sample comme modèle.

Séparer les rôles :

conf/ → fichiers de configuration

sh/ → scripts d’installation

.tf → Terraform pour provisionning et build des VMs

Contact

Pour toute question ou contribution :
Jérôme Quandalle – DevOps, IaC & Cloud Security
