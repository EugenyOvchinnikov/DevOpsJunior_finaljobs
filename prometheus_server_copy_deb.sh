#!/bin/bash

source servers_ip.txt
echo $prometheus_ip
user=yc-user

scp ./prometheus_install.sh $user@$prometheus_ip:~/
scp ./servers_ip.txt $user@$prometheus_ip:~/
scp ./grafana-enterprise_10.2.2_amd64.deb $user@$prometheus_ip:~/
scp ./alert.rules.yml $user@$prometheus_ip:~/
scp ./alertmanager.yml $user@$prometheus_ip:~/