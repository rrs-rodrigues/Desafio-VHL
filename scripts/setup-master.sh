#!/bin/bash

set -e

MASTER_IP=192.168.56.10

echo "Configurando node master com IP: $MASTER_IP"

echo "[1/3] Instando K3s..."
curl -sfL https://get.k3s.io | sh -s - server \
    --node-ip=${MASTER_IP} \
    --bind-address=192.168.56.10 \
    --advertise-address=${MASTER_IP} \
    --write-kubeconfig-mode=644

echo "[2/3] Exportando Token para node worker..."
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token

echo "[3/3] Configurando kubeconfig..."
sudo cp /etc/rancher/k3s/k3s.yaml /vagrant/kubeconfig.yaml
sudo sed -i "s/127.0.0.1/${MASTER_IP}/g" /vagrant/kubeconfig.yaml

sudo kubectl apply -f /vagrant/zabbix-manifest.yml
echo "Node master pronto!"