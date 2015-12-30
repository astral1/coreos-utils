#!/usr/bin/env bash

. `dirname $0`/templates.tpl

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
  local CONF=`cat <<EOF
$(tpl_etcd)
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
