#!/bin/bash

set -e  # Stop on error
set -o pipefail

# ASCII ART d’intro
echo -e "\e[36m"
cat << "EOF"
██╗  ██╗ █████╗ ███████╗    ██████╗ ███████╗ █████╗ ██████╗ ██╗   ██╗██████╗ ██████╗ ██╗   ██╗███╗   ██╗
██║ ██╔╝██╔══██╗██╔════╝    ██╔══██╗██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝╚════██╗██╔══██╗██║   ██║████╗  ██║
█████╔╝ ╚█████╔╝███████╗    ██████╔╝█████╗  ███████║██║  ██║ ╚████╔╝  █████╔╝██████╔╝██║   ██║██╔██╗ ██║
██╔═██╗ ██╔══██╗╚════██║    ██╔══██╗██╔══╝  ██╔══██║██║  ██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║   ██║██║╚██╗██║
██║  ██╗╚█████╔╝███████║    ██║  ██║███████╗██║  ██║██████╔╝   ██║   ███████╗██║  ██║╚██████╔╝██║ ╚████║
╚═╝  ╚═╝ ╚════╝ ╚══════╝    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
               🚀 Deploying Kubernetes Cluster on AlmaLinux 9🚀
EOF
echo -e "\e[0m"
echo


echo "***************************************"
echo "**   Activation de NTP et fuseau     **"
echo "**     horaire Europe/Paris         **"
echo "***************************************"

# Vérification que chronyd est bien installé et actif (par défaut sur Alma)
sudo systemctl enable --now chronyd

# Activation du service NTP via timedatectl
sudo timedatectl set-ntp true

# Configuration du fuseau horaire
sudo timedatectl set-timezone Europe/Paris

# Affichage de l’état final
timedatectl status


echo "***************************************"
echo "** Prérequis                         **"
echo "** Enable IPv4 packet forwarding     **"
echo "***************************************"

# Charger les modules kernel
MODULES_CONF="/etc/modules-load.d/k8s.conf"

sudo dnf install -y kernel-modules-extra-$(uname -r)

if [ ! -f "$MODULES_CONF" ]; then
  echo -e "overlay\nbr_netfilter" | sudo tee "$MODULES_CONF"
else
  echo "ℹ️  $MODULES_CONF existe déjà, on passe."
fi

# Chargement immédiat
sudo modprobe overlay
sudo modprobe br_netfilter

# Désactivation du swap
echo "🔧 Désactivation du swap..."
sudo swapoff -a

if ! grep -E '^[^#].*\bswap\b' /etc/fstab >/dev/null; then
  echo "✅ Aucune ligne swap active dans /etc/fstab"
else
  sudo cp /etc/fstab /etc/fstab.bak
  echo "🛡️  Backup de /etc/fstab créé."
  sudo sed -i '/^\s*[^#].*\bswap\b/ s/^/#/' /etc/fstab
  echo "✅ Ligne swap commentée dans /etc/fstab."
fi

# Paramètres sysctl pour Kubernetes
SYSCTL_CONF="/etc/sysctl.d/k8s.conf"
sudo tee "$SYSCTL_CONF" > /dev/null <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Application des règles sysctl
sudo sysctl --system

# Ajout modules IPVS
IPVS_MODULES_CONF="/etc/modules-load.d/ipvs.conf"
if [ ! -f "$IPVS_MODULES_CONF" ]; then
  echo -e "ip_vs\nip_vs_rr\nip_vs_wrr\nip_vs_sh" | sudo tee "$IPVS_MODULES_CONF"
else
  echo "ℹ️  $IPVS_MODULES_CONF existe déjà, on passe."
fi

# Chargement immédiat des modules IPVS
for module in ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh; do
  sudo modprobe "$module"
done

# socat requis pour kubelet (surtout pour CNI)
sudo dnf install -y epel-release

sudo dnf install -y socat ipvsadm wget curl 

sudo curl -Lo /usr/local/bin/runc https://github.com/opencontainers/runc/releases/latest/download/runc.amd64
sudo chmod +x /usr/local/bin/runc



echo "🚢==============================================="
echo "🚢 [Étape 1] Installation de containerd          "
echo "🚢==============================================="

CRI_VERSION="2.2.0"
ARCH="amd64"
TMPDIR="/tmp/containerd-install"
TARBALL="containerd-${CRI_VERSION}-linux-${ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/containerd/containerd/releases/download/v${CRI_VERSION}/${TARBALL}"


# Installer les dépendances
sudo dnf install -y yum-utils ca-certificates curl gnupg2

# Activer le dépôt "container-tools"
sudo dnf groupinstall -y "Container Management"

mkdir -p "$TMPDIR"
cd "$TMPDIR"

echo "📥 Téléchargement depuis : $DOWNLOAD_URL"
curl -LO "$DOWNLOAD_URL"

echo "📦 Extraction de l'archive..."
sudo tar --no-overwrite-dir -C /usr/local -xzf "$TARBALL"

echo "✅ Binaire containerd installé dans /usr/local/bin"

echo "🛠️ Installation du service systemd containerd..."

sudo tee /etc/systemd/system/containerd.service > /dev/null <<EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStart=/usr/local/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Service systemd créé"

echo "📄 Configuration de containerd par défaut..."

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

echo "🔧 Activation du mode Systemd cgroup dans la config"
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

echo "🚀 Démarrage et activation du service containerd"
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

echo "✅ containerd installé, configuré et démarré"
echo

echo "☸️==============================================="
echo "☸️ [Étape 2] Installation des outils Kubernetes "
echo "☸️==============================================="

# Ajouter le dépôt Kubernetes
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo > /dev/null
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.34/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.34/rpm/repodata/repomd.xml.key
EOF

# Installer kubelet, kubeadm, kubectl
sudo dnf install -y kubelet kubeadm kubectl

# Verrouiller les versions
sudo dnf install -y 'dnf-command(versionlock)'
sudo dnf versionlock add kubelet kubeadm kubectl

# Activer kubelet (ne démarre pas sans init)
sudo systemctl enable kubelet

echo "✅ kubeadm, kubelet, kubectl installés et verrouillés"
echo

echo "🔧==============================================="
echo "🔧 [Étape 3] Configuration systemd pour kubelet "
echo "🔧==============================================="

sudo mkdir -p /etc/systemd/system/kubelet.service.d

sudo tee /etc/systemd/system/kubelet.service.d/0-containerd.conf > /dev/null <<EOF
[Service]
Environment="KUBELET_EXTRA_ARGS=--container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock"
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl restart kubelet

echo "✅ Configuration systemd kubelet avec containerd"
echo

echo "🚀==============================================="
echo "🚀 [Étape 4] Initialisation du cluster K8s       "
echo "🚀==============================================="

# Override systemd kubelet pour containerd
echo "🔧 Configuration systemd kubelet pour containerd"
sudo mkdir -p /etc/systemd/system/kubelet.service.d
sudo tee /etc/systemd/system/kubelet.service.d/override.conf > /dev/null <<EOF
[Service]
Environment="KUBELET_EXTRA_ARGS=--container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --runtime-request-timeout=15m"
EOF

sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Reset kubeadm si cluster existant (pour éviter conflit)
if [ -f /etc/kubernetes/admin.conf ]; then
  echo "⚠️ Cluster Kubernetes existant détecté, reset en cours..."
  sudo kubeadm reset -f
  sudo systemctl restart kubelet
fi

echo "📦 Préchargement des images kubeadm"
sudo kubeadm config images pull --cri-socket unix:///run/containerd/containerd.sock

echo "🚀 Initialisation du cluster Kubernetes"
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket unix:///run/containerd/containerd.sock

echo "🔐 Configuration kubectl local"
mkdir -p "$HOME/.kube"
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"

echo "🌐 Déploiement de Calico CNI"
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo "🔑 Génération du token kubeadm join"
cd ~
kubeadm token create --print-join-command > tok.tok


echo "✅ Cluster initialisé avec containerd 🎉"

echo "🔧 Patch Calico IP_AUTODETECTION_METHOD"
kubectl -n kube-system patch daemonset calico-node \
  --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/env/-", "value": {"name": "IP_AUTODETECTION_METHOD", "value": "can-reach=8.8.8.8"}}]'

kubectl -n kube-system rollout restart daemonset calico-node

echo "✅ Patch Calico appliqué"

