#!/bin/bash

# Создание сети
yc vpc network create \
  --name vpn-server-network \
  --description "network for vpn server"

# Создание подсети
yc vpc subnet create \
  --name vpn-server-subnet-a \
  --zone ru-central1-a \
  --range 10.1.2.0/24 \
  --network-name vpn-server-network \
  --description "subnet for vpn server"

./ca_server_create.sh
./vpn_server_create.sh
./prometheus_server_create.sh
