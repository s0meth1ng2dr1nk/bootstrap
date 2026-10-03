#!/bin/bash
# export PASSWORD='' && sudo --preserve-env=PASSWORD nohup bash -c 'systemctl disable --now dnf-automatic.timer && dnf install -y --setopt=install_weak_deps=False git && git clone -b main https://github.com/s0meth1ng2dr1nk/bootstrap.git /opt/bootstrap && bash /opt/bootstrap/bootstrap.sh' > /tmp/bootstrap.log 2>&1 &
# openssl enc -aes-256-cbc -salt -pbkdf2 -pass env:PASSWORD -in secret.env | base64 -w 0 > secret.enc.b64
set -euo pipefail

BASE=$(cd $(dirname "${BASH_SOURCE[0]:-0}") && pwd -P)
cd "${BASE}"

init() {
  if [ ! -f /swapfile ]; then
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
  fi

  if ! swapon --show=NAME | grep -qxF /swapfile; then
    swapon /swapfile
  fi

  grep -qxF '/swapfile none swap sw 0 0' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab

  dnf install -y --setopt=install_weak_deps=False openssl
  base64 -d config/secret.enc.b64 | openssl enc -d -aes-256-cbc -pbkdf2 -pass env:PASSWORD -out config/secret.env
  echo "export PASSWORD=${PASSWORD}" >> config/secret.env
  (
    cd script
    ln -nfs ../config/common.env
    ln -nfs ../config/secret.env
  )
}

init

cd script

bash update.sh
bash git.sh

bash python.sh
bash nodejs.sh
bash docker.sh

bash skill.sh

bash cleanup.sh

bash ssh.sh
