#!/bin/bash

if [ $# -eq 0 ]
then
echo "Нужно имя клиента в качестве аргумента"
exit 1
fi
name=$1

source servers_ip.txt
echo $vpn_server_ip

user=yc-user

scp $user@$vpn_server_ip:~/easy-rsa-master/clients/files/$name.ovpn ./