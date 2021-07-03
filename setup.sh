#!/bin/bash
set -ex
if command -v git &> /dev/null
then
  git log -n 1 --date=format:%Y%m%d --pretty=format:%cd.%h > vm-version.txt 2> /dev/null || true
fi
vagrant destroy || true
vagrant box update || true
export FIRST_RUN='true'
vagrant up --no-provision
if [[ -z "${NO_SEL4}" ]]; then
  vagrant ssh -c 'bash /vagrant/snapshot.sh'
fi
vagrant ssh -c 'sudo apt-get update'
vagrant ssh -c 'sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y'
vagrant ssh -c 'sudo DEBIAN_FRONTEND=noninteractive apt install -y build-essential linux-headers-amd64 linux-image-amd64 python-pip'
vagrant halt
export FIRST_RUN='false'
vagrant up || true
vagrant reload
vagrant reload
