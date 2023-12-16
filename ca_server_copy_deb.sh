#!/bin/bash

source servers_ip.txt
echo $ca_ip

user=yc-user

scp ./easy-rsa_0.1-1_all.deb $user@$ca_ip:~/
scp ./easy-rsa-vars_0.1-1_all.deb $user@$ca_ip:~/
scp ./easy_rsa_install.sh $user@$ca_ip:~/
scp ~/.ssh/id_ed25519 $user@$ca_ip:~/.ssh/