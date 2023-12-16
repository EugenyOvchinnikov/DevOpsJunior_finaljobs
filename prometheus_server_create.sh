#!/bin/bash

# Создание сети
# yc vpc network create \
#   --name vpn-server-network \
#   --description "network for vpn server"

# Создание подсети
# yc vpc subnet create \
#   --name vpn-server-subnet-a \
#   --zone ru-central1-a \
#   --range 10.1.2.0/24 \
#   --network-name vpn-server-network \
#   --description "subnet for vpn server"

# Создание ВМ, постоянный IP, ram 1 Gb, 2 ядра, 20% загрузки процессора
yc compute instance create \
  --name prometheus-server \
  --preemptible \
  --memory 1 --cores 2 --core-fraction 20 \
  --network-interface subnet-name=vpn-server-subnet-a,nat-ip-version=ipv4 \
  --zone ru-central1-a \
  --ssh-key ~/.ssh/id_ed25519.pub
