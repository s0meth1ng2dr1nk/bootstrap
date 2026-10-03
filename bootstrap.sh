#!/bin/bash
# export PASSWORD='' && curl -fsSL https://raw.githubusercontent.com/s0meth1ng2dr1nk/bootstrap/main/bootstrap.sh | sudo --preserve-env=PASSWORD bash
# openssl enc -aes-256-cbc -salt -pbkdf2 -pass env:PASSWORD -in secret.env | base64 -w 0 > secret.enc.b64
set -euo pipefail

GIT_USER=s0meth1ng2dr1nk
REPO='https://github.com/${GIT_USER}/bootstrap'
BRANCH='main'

setup_config() {
  curl -fsSL "${REPO}/archive/refs/heads/${BRANCH}.tar.gz" | tar -xz --strip-components=1
  base64 -d config/secret.enc.b64 | openssl enc -d -aes-256-cbc -pbkdf2 -pass env:PASSWORD -out config/secret.env
  source config/secret.env
  rm -f config/secret.env
}

setup_swap() {
  fallocate -l 4G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
}

setup_update() {
  dnf update -y
}

setup_python() {
  dnf install -y python3 python3-pip
}

setup_nodejs() {
  dnf install -y nodejs npm
}

setup_docker() {
  dnf install -y dnf-plugins-core
  dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
  dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable --now docker
}

setup_git() {
  curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash
  dnf install -y git-lfs
  git lfs install --system

  git config --global credential.helper store
  echo "https://${GIT_USER}:${GIT_PAT}@github.com" > ${HOME}/.git-credentials
}

setup_ai() {
  git clone -b main https://github.com/ayghri/i-have-adhd /opt/skill/i-have-adhd
}

setup_ssh() {
  echo "root:${PASSWORD}" | chpasswd
  grep -rl ssh_pwauth /etc/cloud | xargs -r sed -i -E -e 's@^ssh_pwauth.*@ssh_pwauth:true@'
  grep -rl PasswordAuthentication /etc/ssh | xargs -r sed -i -E \
    -e 's@^PasswordAuthentication@#PasswordAuthentication@' \
    -e 's@^PasswordAuthentication@#PasswordAuthentication@' \
    -e 's@^PermitRootLogin@#PermitRootLogin@' \
    -e 's@^UsePAM@#UsePAM@' \
    -e '$aPasswordAuthentication yes' \
    -e '$aPermitRootLogin yes' \
    -e '$aUsePAM yes'
  systemctl restart ssh*
}

cleanup() {
  dnf clean all
  rm -rf /var/cache/dnf/* /var/cache/yum/* config
}

# setup claude
wget --no-cache https://claude.ai/install.sh -O install.sh
bash install.sh
rm -f install.sh
echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> /etc/profile


setup_swap

setup_update

setup_python
setup_nodejs
setup_docker
setup_git

setup_ai

setup_ssh

cleanup
