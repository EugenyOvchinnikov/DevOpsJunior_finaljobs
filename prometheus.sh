#!/bin/bash

sudo apt install prometheus prometheus-alertmanager prometheus-node-exporter prometheus-nginx-exporter
cat /etc/prometheus/prometheus.yml - таргеты
vi /etc/prometheus/rules.yml - алерты

rule_files:
  - rules.yml


  - job_name: "ca server"
    static_configs:
      - targets: ['51.250.77.154:9100']

  - job_name: "vpn server"
    static_configs:
      - targets: ['51.250.90.174:9100']

wget https://golang.org/dl/go1.15.2.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.15.2.linux-amd64.tar.gz
vim /etc/environment PATH=$PATH:/usr/local/go/bin
source /etc/environment
или export PATH=$PATH:/usr/local/go/bin

wget https://github.com/kumina/openvpn_exporter/archive/v0.3.0.tar.gz
tar xzf v0.3.0.tar.gz
cd openvpn_exporter-0.3.0/
vi main.go

openvpnStatusPaths = flag.String("openvpn.status_paths", "/var/log/openvpn/openvpn-status.log"

sudo /usr/local/go/bin/go build -o /usr/local/bin/openvpn_exporter main.go

http://51.250.90.174:9176/metrics



cat > /etc/systemd/system/openvpn_exporter.service << 'EOF'
[Unit]
Description=Prometheus OpenVPN Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/openvpn_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now openvpn_exporter.service

Running OpenVPN Node Exporter as a Service
vi /etc/systemd/system/openvpn_exporter.service
[Unit]
Description=Prometheus OpenVPN Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/openvpn_exporter

[Install]
WantedBy=multi-user.target
systemctl daemon-reload
systemctl enable --now openvpn_exporter.service






## Add OpenVPN Node Exporter
- job_name: 'openvpn-metrics'
  scrape_interval: 5s
  static_configs:
  - targets:
    - <IP-OpenVPN-Server>:9176













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
unzip ~/master.zip -d ~/
rm -rf ~/master.zip
rm ./easy-rsa_0.1-1_all.deb
echo "easy-rsa установлен"

# Установка пакета easy-rsa-vars
dpkg -i easy-rsa-vars_0.1-1_all.deb
rm ./easy-rsa-vars_0.1-1_all.deb
echo "easy-rsa-vars установлен"

# Инициализируем инфраструктуру публичных ключей
cd ~/easy-rsa-master/easyrsa3
./easyrsa init-pki

# Запрос на сертификат
./easyrsa gen-req server nopass

chown -R yc-user ~/easy-rsa-master/

# Установка openvpn
apt-get install openvpn
echo "openvpn установлен"

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

# Настраиваем firewall
cd ~/
./iptables.sh

echo "vpn server настроен"
echo "выполните команду sudo ./make_client_keys.sh"
