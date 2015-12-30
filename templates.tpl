#!/usr/bin/env bash
# vi: ft=sh :

function tpl_etcd {
  local IP=`ifconfig en0 | grep 'inet ' | awk '{print $2}'`
  local CONF=`cat <<EOF
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
EOF`

  cat <<EOF
$CONF
EOF
}

