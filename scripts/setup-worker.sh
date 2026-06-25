#!/bin/bash

set -e

MASTER_IP=192.168.56.100
WORKER_IP=192.168.56.101

echo "Configurando node worker com IP: $WORKER_IP"

echo "[1/2] Copiando token..."
while [ ! -f /vagrant/node-token ]; do
  echo "Aguardando o Control Plane gerar o token..."
  sleep 3
done

TOKEN=$(sudo cat /vagrant/node-token)

echo "[2/2] Instando K3s..."
curl -sfL https://get.k3s.io | K3S_URL=https://${MASTER_IP}:6443 K3S_TOKEN=${TOKEN} sh -s - agent \
    --node-ip=${WORKER_IP}

echo "Node worker pronto!"