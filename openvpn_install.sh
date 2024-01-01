#!/bin/bash

source servers_ip.txt

function isRoot() {
	if [ "$EUID" -ne 0 ]; then
		return 1
	fi
}

function tunAvailable() {
	if [ ! -e /dev/net/tun ]; then
		return 1
	fi
}

function checkInstall() {
	if dpkg -l $1 &> /dev/null; then
		echo "--------------------"
		echo "Package $1 installed"
		echo "--------------------"
		else 
			echo "----------------------------------------------"
			echo -e "Warning!\nPackage $1 not installed"
			echo "Fix the problem and try the installation again"
			echo "----------------------------------------------"
		exit 1
	fi
}

function checkService() {
	if sudo service $1 status &> /dev/null; then
		echo "--------------------"
		echo "Service $1 is active"
		echo "--------------------"
		else 
			echo "----------------------------------------------"
			echo -e "Warning!\nService $1 not active"
			echo "Fix the problem and try the installation again"
			echo "----------------------------------------------"
		exit 1
	fi
}

if ! isRoot; then
      echo "Sorry, you need to run this as root"
	exit 1
fi

if ! tunAvailable; then
	echo "TUN is not available"
	exit 1
fi

      # Обновление OS
apt-get update
apt-get upgrade

      # Установка unzip
apt-get install unzip -y
checkInstall unzip

      # Синхронизация времени 
apt-get install ntpdate
checkInstall ntpdate
apt-get install -y ntp
checkInstall ntp
/etc/init.d/ntp stop
ntpdate pool.ntp.org
/etc/init.d/ntp start

# Проверка установленного пакета easy-rsa-vars (удаление при наличии)
if dpkg -l easy-rsa >/dev/null
then dpkg -P easy-rsa-vars
fi

# Проверка установленного пакета easy-rsa (удаление при наличии)
if dpkg -l easy-rsa >/dev/null
then dpkg -P easy-rsa
fi

# Проверка наличия директории openvpn. Если есть то удаляем и создаем заново
if [[ -e /etc/openvpn ]]; then
   rm -rf /etc/openvpn
   echo "Удалена старая директория openvpn"
fi
mkdir /etc/openvpn; mkdir /etc/openvpn/server
echo "создана новая дирктория openvpn"

# Проверка наличия директории easy-rsa-master. Если есть то удаляем
if [[ -e ~/easy-rsa-master ]]; then
   rm -rf ~/easy-rsa-master
   echo "Удалена старая директория easy-rsa-master"
fi

# Установка пакета easy-rsa
dpkg -i easy-rsa_0.1-1_all.deb
checkInstall easy-rsa
unzip ~/master.zip -d ~/
rm -rf ~/master.zip
rm ./easy-rsa_0.1-1_all.deb

# Установка пакета easy-rsa-vars
dpkg -i easy-rsa-vars_0.1-1_all.deb
checkInstall easy-rsa-vars
rm ./easy-rsa-vars_0.1-1_all.deb

# Инициализируем инфраструктуру публичных ключей
cd ~/easy-rsa-master/easyrsa3
./easyrsa init-pki

# Запрос на сертификат
./easyrsa gen-req server nopass

chown -R yc-user ~/easy-rsa-master/

# Установка openvpn
apt-get install openvpn
checkInstall openvpn

adduser --system --no-create-home --home /nonexistent --disabled-login --group openvpn

mkdir /etc/openvpn/ccd


chown -R yc-user /etc/openvpn

# Копируем ключ сервера
cp ~/easy-rsa-master/easyrsa3/pki/private/server.key /etc/openvpn/server/

# Отправляем запрос на CA
sudo -u yc-user scp ~/easy-rsa-master/easyrsa3/pki/reqs/server.req yc-user@$ca_ip:~/

# Импорт запроса
sudo -u yc-user ssh yc-user@$ca_ip "
cd /home/yc-user/easy-rsa-master/easyrsa3
./easyrsa import-req /home/yc-user/server.req vpn-server"

# Подписываем запрос
sudo -u yc-user ssh yc-user@$ca_ip "
cd /home/yc-user/easy-rsa-master/easyrsa3
yes yes | ./easyrsa sign-req server vpn-server"

# Копируем ключи на vpn-server
sudo -u yc-user scp yc-user@$ca_ip:/home/yc-user/easy-rsa-master/easyrsa3/pki/issued/vpn-server.crt /etc/openvpn/server
sudo -u yc-user scp yc-user@$ca_ip:/home/yc-user/keys/ca.crt /etc/openvpn/server
sudo -u yc-user scp yc-user@$ca_ip:/home/yc-user/keys/crl.pem /etc/openvpn/server

/usr/sbin/openvpn --genkey --secret /etc/openvpn/server/ta.key

cp ~/server.conf /etc/openvpn/server/

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
echo "server is router"

systemctl enable openvpn-server@server.service --now
checkService openvpn-server@server

# node_exporter install
cd ~/
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvf node_exporter-1.3.1.linux-amd64.tar.gz
cd node_exporter-1.3.1.linux-amd64
cp node_exporter /usr/local/bin

useradd --no-create-home --shell /bin/false node_exporter
chown node_exporter:node_exporter /usr/local/bin/node_exporter

cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter
checkService node_exporter

cd ~
./openvpn_exporter_install.sh
checkService openvpn_exporter

# Настраиваем firewall
cd ~/
./iptables.sh

echo "vpn server настроен"
echo "выполните команду sudo ./make_client_keys.sh"
