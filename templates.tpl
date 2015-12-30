#!/usr/bin/env bash
# vi: ft=sh :

function tpl_etcd {
  local IP=`ifconfig en0 | grep 'inet ' | awk '{print $2}'`

  cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>KeepAlive</key>
    <dict>
      <key>SuccessfulExit</key>
      <false/>
    </dict>
    <key>Label</key>
    <string>homebrew.mxcl.etcd</string>
    <key>ProgramArguments</key>
    <array>
      <string>$(brew --prefix)/opt/etcd/bin/etcd</string>
      <string>--listen-client-urls</string>
      <string>http://0.0.0.0:2379,http://0.0.0.0:4001</string>
      <string>--advertise-client-urls</string>
      <string>http://$IP:2379,http://$IP:4001,http://192.168.64.1:2379,http://192.168.64.1:4001</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$(brew --prefix)/var/log/etcd.log</string>
    <key>StandardErrorPath</key>
    <string>$(brew --prefix)/var/log/etcd.log</string>
    <key>WorkingDirectory</key>
    <string>$(brew --prefix)/var</string>
  </dict>
</plist>
EOF
}

function tpl_cloud {
  local CLUSTER=`echo -n $1 | shasum | awk '{print $1}'`

  cat <<EOF
#cloud-config
---
coreos:
  etcd2:
    discovery: "http://192.168.64.1:2379/v2/keys/discovery/$CLUSTER"
    advertise-client-urls: "http://\$public_ipv4:2379"
    initial-advertise-peer-urls: "http://\$private_ipv4:2380"
    listen-client-urls: "http://0.0.0.0:2379,http://0.0.0.0:4001"
    listen-peer-urls: "http://\$private_ipv4:2380,http://\$private_ipv4:7001"
  fleet:
    public-ip: "\$public_ipv4"
    metadata: "region=coupang"
  flannel:
    etcd_prefix: "/coreos.com/network"
  units:
    - name: "etcd2.service"
      command: "start"
    - name: "fleet.service"
      command: "start"
    - name: "flanneld.service"
      drop-ins:
        - name: 50-network-config.conf
          content: |
            [Service]
            ExecStartPre=/usr/bin/etcdctl set /coreos.com/network/config '{ "Network": "172.24.0.0/16" }'
      command: "start"
    - name: "docker.service"
      command: "start"
      drop-ins:
        - name: 40-flannel.conf
          content: |
            [Unit]
            Requires=flanneld.service
            After=flanneld.service
ssh_authorized_keys:
  - "$(cat $HOME/.ssh/id_rsa.pub)"
EOF
}
