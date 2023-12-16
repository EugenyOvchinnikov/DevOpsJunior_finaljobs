#!/bin/bash

source servers_ip.txt
echo $vpn_server_ip
user=yc-user

scp ./easy-rsa_0.1-1_all.deb $user@$vpn_server_ip:~/
scp ./easy-rsa-vars_0.1-1_all.deb $user@$vpn_server_ip:~/
scp ./openvpn_install.sh $user@$vpn_server_ip:~/
scp ./server.conf $user@$vpn_server_ip:~/
scp ~/.ssh/id_ed25519 $user@$vpn_server_ip:~/.ssh/
scp ./servers_ip.txt $user@$vpn_server_ip:~/
scp ./base.conf $user@$vpn_server_ip:~/
scp ./make_client_keys.sh $user@$vpn_server_ip:~/
scp ./make_config.sh $user@$vpn_server_ip:~/
scp ./iptables.sh $user@$vpn_server_ip:~/
scp ./openvpn_exporter_install.sh $user@$vpn_server_ip:~/
scp ./main.go $user@$vpn_server_ip:~/