#!/bin/bash

# First argument: Client identifier

source ~/servers_ip.txt
echo $vpn_server_ip

KEY_DIR=~/easy-rsa-master/clients/keys
OUTPUT_DIR=~/easy-rsa-master/clients/files
BASE_CONFIG=~/easy-rsa-master/clients/base.conf

echo "remote $vpn_server_ip 1194" >> ~/base.conf
cp ~/base.conf ~/easy-rsa-master/clients/

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${1}.key \
    <(echo -e '</key>\n<tls-crypt>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-crypt>') \
    > ${OUTPUT_DIR}/${1}.ovpn
