#!/bin/bash

set -e

MASTER_IP=192.168.56.10

echo "Configurando node master com IP: $MASTER_IP"

echo "[1/6] Instando K3s..."
curl -sfL https://get.k3s.io | sh -s - server \
    --node-ip=${MASTER_IP} \
    --bind-address=192.168.56.10 \
    --advertise-address=${MASTER_IP} \
    --write-kubeconfig-mode=644

echo "[2/6] Exportando Token para node worker..."
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token

echo "[3/6] Configurando kubeconfig..."
sudo cp /etc/rancher/k3s/k3s.yaml /vagrant/kubeconfig.yaml
sudo sed -i "s/127.0.0.1/${MASTER_IP}/g" /vagrant/kubeconfig.yaml

echo "[4/6] Node master pronto!"

echo "[5/6] Aplicando manifestos do Zabbix..."
sudo kubectl apply -f /vagrant/zabbix-manifest.yml
sudo kubectl apply -f /vagrant/zabbix-ingress.yml

echo "[6/6] Manifestos aplicados com sucesso!"


