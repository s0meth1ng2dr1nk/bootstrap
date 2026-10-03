#!/bin/bash
# export PASSWORD='' && sudo systemctl disable --now dnf-automatic.timer && sudo dnf install -y git && sudo git clone -b main https://github.com/s0meth1ng2dr1nk/bootstrap.git /opt/bootstrap && sudo --preserve-env=PASSWORD bash /opt/bootstrap/bootstrap.sh
# openssl enc -aes-256-cbc -salt -pbkdf2 -pass env:PASSWORD -in secret.env | base64 -w 0 > secret.enc.b64
set -euo pipefail

BASE=$(cd $(dirname "${BASH_SOURCE[0]:-0}") && pwd -P)
cd "${BASE}"

init() {
  dnf install -y openssl
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

bash swap.sh

bash update.sh
bash git.sh

bash python.sh
bash nodejs.sh
bash docker.sh

bash skill.sh

bash cleanup.sh

bash ssh.sh
