#!/bin/bash

# Создание ВМ, постоянный IP, ram 1 Gb, 2 ядра, 20% загрузки процессора
yc compute instance create \
  --name vpn-server \
  --preemptible \
  --memory 1 --cores 2 --core-fraction 20 \
  --network-interface subnet-name=vpn-server-subnet-a,nat-ip-version=ipv4 \
  --zone ru-central1-a \
  --ssh-key ~/.ssh/id_ed25519.pub
