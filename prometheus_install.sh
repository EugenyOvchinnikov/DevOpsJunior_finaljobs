#!/bin/bash
source servers_ip.txt

wget https://github.com/prometheus/prometheus/releases/download/v2.48.1/prometheus-2.48.1.linux-amd64.tar.gz

tar xvf prometheus-2.48.1.linux-amd64.tar.gz

cd prometheus-2.48.1.linux-amd64

mv prometheus promtool /usr/local/bin/

mkdir /etc/prometheus
mv prometheus.yml /etc/prometheus/prometheus.yml
mv consoles/ console_libraries/ /etc/prometheus/

echo -e "\
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
>> /etc/prometheus/prometheus.yml

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

systemctl daemon-reload
systemctl enable prometheus"\
EOF

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
systemctl start node_exporter
systemctl enable prometheus

apt-get install prometheus-alertmanager

# node_cpu_seconds_total{mode="iowait"}
# node_filesystem_avail_bytes{fstype!="tmpfs", mountpoint="/"}/node_filesystem_size_bytes*100
# 100-avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) without (cpu) * 100
# node_load15{instance="localhost:9100", job="node"}
