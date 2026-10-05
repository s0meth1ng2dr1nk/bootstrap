#!/bin/bash
# export PASSWORD='' && sudo --preserve-env=PASSWORD nohup bash -c 'systemctl disable --now dnf-automatic.timer && dnf install -y --setopt=install_weak_deps=False git && rm -rf /opt/bootstrap && git clone -b main --depth 1 https://github.com/s0meth1ng2dr1nk/bootstrap.git /opt/bootstrap && bash /opt/bootstrap/bootstrap.sh' > /tmp/bootstrap.log 2>&1 &
# openssl enc -aes-256-cbc -salt -pbkdf2 -pass env:PASSWORD -in keys.txt | base64 -w 0 > keys.enc.b64
set -euox pipefail

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
  base64 -d keys.enc.b64 | openssl enc -d -aes-256-cbc -pbkdf2 -pass env:PASSWORD -out keys.txt
  export SOPS_AGE_KEY_FILE="${BASE}/keys.txt"

  curl -sSLO $(curl -s https://api.github.com/repos/getsops/sops/releases/latest | grep "browser_download_url.*x86_64.rpm" | cut -d : -f 2,3 | tr -d \")
  dnf localinstall -y sops-*.x86_64.rpm
  rm -f sops-*.x86_64.rpm
  sops -d config/secret.sops.env > config/secret.env

  echo "export SOPS_AGE_KEY_FILE=${SOPS_AGE_KEY_FILE}" >> config/secret.env
  echo "export PASSWORD=${PASSWORD}" >> config/secret.env
  sed -i -e '/\/config\/secret\.env/d' -e "$ a [ -f ${BASE}/config/secret.env ] && source ${BASE}/config/secret.env" /etc/profile

  (
    cd script
    ln -nfs ${BASE}/config/common.env
    ln -nfs ${BASE}/config/secret.env
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

echo
echo "done"
