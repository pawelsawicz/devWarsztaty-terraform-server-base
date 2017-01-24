export IP_ADDRESS=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo $IP_ADDRESS

sudo mkdir -p /etc/nomad

# Nomad server config
sudo cat > server.hcl <<EOF
addresses {
    rpc  = "ADVERTISE_ADDR"
    serf = "ADVERTISE_ADDR"
}
advertise {
    http = "ADVERTISE_ADDR:4646"
    rpc  = "ADVERTISE_ADDR:4647"
    serf = "ADVERTISE_ADDR:4648"
}
bind_addr = "0.0.0.0"
data_dir  = "/var/lib/nomad"
log_level = "DEBUG"
server {
    enabled = true
    bootstrap_expect = 3
}
EOF

sudo sed -i "s/ADVERTISE_ADDR/${IP_ADDRESS}/" server.hcl
sudo mv server.hcl /etc/nomad/server.hcl

# Nomad Service setup

cat > nomad.service <<'EOF'
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/
[Service]
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF
sudo mv nomad.service /etc/systemd/system/nomad.service

sudo systemctl enable nomad
sudo systemctl start nomad

# Consul service setup
cat > consul.service <<'EOF'
[Unit]
Description=consul
Documentation=https://consul.io/docs/
[Service]
ExecStart=/usr/local/bin/consul agent \
  -advertise=ADVERTISE_ADDR \
  -bind=0.0.0.0 \
  -bootstrap-expect=3 \
  -client=0.0.0.0 \
  -data-dir=/var/lib/consul \
  -server \
  -ui

ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

sudo sed -i "s/ADVERTISE_ADDR/${IP_ADDRESS}/" consul.service
sudo mv consul.service /etc/systemd/system/consul.service
sudo systemctl enable consul
sudo systemctl start consul

# Dnsmasq service setup

sudo mkdir -p /etc/dnsmasq.d
sudo cat > 10-consul <<'EOF'
server=/consul/127.0.0.1#8600
EOF

sudo mv 10-consul /etc/dnsmasq.d/10-consul

#sudo systemctl enable dnsmasq
#sudo systemctl start dnsmasq
