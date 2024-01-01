#!/bin/bash

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

source servers_ip.txt

wget https://github.com/prometheus/prometheus/releases/download/v2.48.1/prometheus-2.48.1.linux-amd64.tar.gz

tar xvf prometheus-2.48.1.linux-amd64.tar.gz

cd prometheus-2.48.1.linux-amd64

mv prometheus promtool /usr/local/bin/

mkdir /etc/prometheus
mkdir /var/log/prometheus
mkdir /var/lib/prometheus
mv prometheus.yml /etc/prometheus/prometheus.yml
mv consoles/ console_libraries/ /etc/prometheus/

echo -e "\
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

rule_files:
 - alert.rules.yml

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
      - targets:
        - localhost:9093

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  - job_name: "node"
    static_configs:
      - targets: ['localhost:9100']
  
  - job_name: "ca server"
    static_configs:
      - targets: ['$ca_ip:9100']

  - job_name: "vpn server"
    static_configs:
      - targets: ['$vpn_server_ip:9100']

# Add OpenVPN Node Exporter
  - job_name: 'openvpn-metrics'
    scrape_interval: 5s
    static_configs:
      - targets: ['$vpn_server_ip:9176']"\
> /etc/prometheus/prometheus.yml

cat > /etc/systemd/system/prometheus.service << 'EOF'
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/prometheus \
--config.file=/etc/prometheus/prometheus.yml \
--storage.tsdb.path=/var/lib/prometheus \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries \
--web.listen-address=0.0.0.0:9090 \
--web.external-url=

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

mv ~/alert.rules.yml /etc/prometheus

useradd --no-create-home --shell /bin/false prometheus
chown -R prometheus:prometheus /etc/prometheus /var/log/prometheus /var/lib/prometheus
chown prometheus:prometheus /usr/local/bin/{prometheus,promtool} 

systemctl daemon-reload

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

systemctl enable prometheus
systemctl start prometheus
checkService prometheus

# Install alertmanager
cd ~
wget https://github.com/prometheus/alertmanager/releases/download/v0.24.0/alertmanager-0.24.0.linux-amd64.tar.gz
tar xvf alertmanager-0.24.0.linux-amd64.tar.gz
rm alertmanager-0.24.0.linux-amd64.tar.gz
mkdir /etc/alertmanager /var/lib/prometheus/alertmanager
cd alertmanager-0.24.0.linux-amd64
cp alertmanager amtool /usr/local/bin/ && cp alertmanager.yml /etc/alertmanager
useradd --no-create-home --shell /bin/false alertmanager
chown -R alertmanager:alertmanager /etc/alertmanager /var/lib/prometheus/alertmanager
chown alertmanager:alertmanager /usr/local/bin/{alertmanager,amtool}

cat > /etc/systemd/system/alertmanager.service << 'EOF'
[Unit]
Description=Alertmanager Service
After=network.target

[Service]
EnvironmentFile=-/etc/default/alertmanager
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/local/bin/alertmanager \
--config.file=/etc/alertmanager/alertmanager.yml \
--storage.path=/var/lib/prometheus/alertmanager \
--cluster.advertise-address="127.0.0.1:9093"\
$ALERTMANAGER_OPTS
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable alertmanager
systemctl start alertmanager
checkService alertmanager
