#!/usr/bin/env bash

function usage {
  local PROG=`basename $0`
  echo "$PROG:"
  echo "  $PROG new <cluster name>: create new cluster"
}

function new {
  local NAME=$1
  local SIZE=${2:-1}
  local CLUSTER=`echo -n $NAME | shasum | awk '{print $1}'`

  _config_etcd

  etcdctl ls discovery/$CLUSTER &> /dev/null
  local EXIST=$?
  local CMD=mk
  [[ $EXIST -eq 0 ]] && CMD=update
  etcdctl $CMD discovery/$CLUSTER/_config/size $SIZE &> /dev/null
  echo $CLUSTER
}

function _config_etcd {
  local CONFIG_PATH=`brew --prefix`/opt/etcd/homebrew.mxcl.etcd.plist
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
      <string>`brew --prefix`/opt/etcd/bin/etcd</string>
      <string>--listen-client-urls</string>
      <string>http://0.0.0.0:2379,http://0.0.0.0:4001</string>
      <string>--advertise-client-urls</string>
      <string>http://$IP:2379,http://$IP:4001,http://192.168.64.1:2379,http://192.168.64.1:4001</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>`brew --prefix`/var/log/etcd.log</string>
    <key>StandardErrorPath</key>
    <string>`brew --prefix`/var/log/etcd.log</string>
    <key>WorkingDirectory</key>
    <string>`brew --prefix`/var</string>
  </dict>
</plist>
EOF`
  local CONFHASH=8a0329384a377ddf78f9c726adcf4447c0c7a92d

  if [ $CONFHASH != `shasum $CONFIG_PATH | awk '{print $1}'` ]; then
    cp $CONFIG_PATH{,.backup} 
    cat <<EOF > $CONFIG_PATH
$CONF
EOF
    echo "Update etcd launchd configuration"
    echo "Restart etcd"
    ln -sfv `brew --prefix`/opt/etcd/*.plist ~/Library/LaunchAgents
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.etcd.plist &> /dev/null
    launchctl stop homebrew.mxcl.etcd
    launchctl start homebrew.mxcl.etcd
  fi
}

COMMAND=$1
shift

case $COMMAND in
  new)
    `dirname $0`/prereq.sh
    new $@
    ;;
  *)
    usage
    ;;
esac
