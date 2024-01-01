#!/bin/bash

source servers_ip.txt

function isRoot() {
	if [ "$EUID" -ne 0 ]; then
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

# Обновление OS
apt-get update
apt-get upgrade

# Установка unzip
apt-get install unzip -y

checkInstall unzip

# Синхронизация времени 
apt-get install ntpdate
apt-get install -y ntp
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
# Создаем сертификат корневого центра сертификации
./easyrsa build-ca nopass
# crl для информации об активных/отозванных сертификатах
./easyrsa gen-crl
# Копируем все что создали в папку keys
mkdir ~/keys
cp ~/easy-rsa-master/easyrsa3/pki/ca.crt ~/keys/
cp ~/easy-rsa-master/easyrsa3/pki/crl.pem ~/keys/
echo "ключи скопированы"

chown -R yc-user ~/easy-rsa-master ~/keys

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

# Настройка firewall. Закрываем всё кроме ssh
# Политика по умолчанию DROP
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

# Разрешаем входящие соединения по ssh
iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# Разрешаем исходящие соединения по ssh
iptables -A OUTPUT -o eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# Разрешаем входящие соединения node exporter
iptables -A INPUT -i eth0 -p tcp --dport 9100 -s $prometheus_ip -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 9100 -m state --state ESTABLISHED -j ACCEPT

# Сохраняем правила
mkdir /etc/iptables
chown -R yc-user /etc/iptables
iptables-save > /etc/iptables/rules.v4

# Добавляем в автозагрузку
echo "re-up iptables-restore < /etc/iptables/rules.v4" >> /etc/network/interfaces

echo "CA настроен"