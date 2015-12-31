CoreOS Utils
============

Utility Scripts for [corectl](https://github.com/TheNewNormal/corectl)

Prerequisite
------------

- [xhyve](https://github.com/mist64/xhyve)
- [corectl](https://github.com/TheNewNormal/corectl)
- [etcd](https://github.com/coreos/etcd)
- [fleetctl](https://github.com/coreos/fleet)

Quickstart for impatient
------------------------

```sh
git clone https://github.com/astral1/coreos-utils.git
cd coreos-utils
./cluster.sh kickstart
```

Usage
-----

```
USAGE for cluster.sh:
  cluster.sh kickstart:
      create and run new cluster named 'coreos' for test or develop
  cluster.sh new <cluster name> [<cluster initial size>]:
      create new cluster. default initial size is 1.
  cluster.sh run <cluster name> [<cluster size>]:
      run new cluster. default size is 1. if cluster size is less than initial size, it will be modified to initial size.
  cluster.sh stop <cluster name>:
      stop running cluster. kill all hosts
  cluster.sh del <cluster name>:
      delete new cluster.
  cluster.sh clean <cluster name>:
      remove all members from cluster.
```
