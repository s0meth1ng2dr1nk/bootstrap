#!/bin/bash
set -euo pipefail

dnf install -y --setopt=install_weak_deps=False dnf-plugins-core
if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
  dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
fi
dnf install -y --setopt=install_weak_deps=False docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker
