#!/bin/bash

function isRoot() {
	if [ "$EUID" -ne 0 ]; then
		return 1
	fi
}

if ! isRoot; then
      echo "Sorry, you need to run this as root"
	exit 1
fi

if [ $# -eq 0 ]
then
echo "Нужно имя клиента в качестве аргумента"
exit 1
fi
name=$1

echo "Input argument exists."
source servers_ip.txt
echo $ca_ip

cd ~/easy-rsa-master/easyrsa3/
mkdir -p ../clients/keys
mkdir -p ../clients/files

./easyrsa gen-req $name nopass

cp pki/reqs/$name.req ../clients/keys/
cp pki/private/$name.key ../clients/keys/

chown -R yc-user ~/easy-rsa-master/clients

# Копируем запрос на CA
sudo -u yc-user scp ~/easy-rsa-master/clients/keys/$name.req yc-user@$ca_ip:~/

# Импорт запроса
sudo -u yc-user ssh yc-user@$ca_ip "
cd /home/yc-user/easy-rsa-master/easyrsa3
./easyrsa import-req /home/yc-user/$name.req $name"

# Подписываем ключ
sudo -u yc-user ssh yc-user@$ca_ip "
cd /home/yc-user/easy-rsa-master/easyrsa3
yes yes | ./easyrsa sign-req client $name"

# Копируем ключ на vpn server
sudo -u yc-user scp yc-user@$ca_ip:/home/yc-user/easy-rsa-master/easyrsa3/pki/issued/$name.crt ~/easy-rsa-master/clients/keys/

cp /etc/openvpn/server/ta.key ../clients/keys
cp /etc/openvpn/server/ca.crt ../clients/keys

# Генерируем файл настроек клиента
cp ~/make_config.sh ~/easy-rsa-master/clients/
cd ~/easy-rsa-master/clients
./make_config.sh $name