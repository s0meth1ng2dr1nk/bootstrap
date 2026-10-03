#!/bin/bash
set -euo pipefail

BASE=$(cd $(dirname "${BASH_SOURCE[0]:-0}") && pwd -P)
cd "${BASE}"
source secret.env
SSHD_CONFIG=/etc/ssh/sshd_config

set_sshd_config() {
  local key="$1"
  local value="$2"
  if grep -qE "^[[:space:]]*#?[[:space:]]*${key}[[:space:]]" "${SSHD_CONFIG}"; then
    sed -i -E "s@^[[:space:]]*#?[[:space:]]*${key}[[:space:]].*@${key} ${value}@" "${SSHD_CONFIG}"
  else
    echo "${key} ${value}" >> "${SSHD_CONFIG}"
  fi
}

echo "root:${PASSWORD}" | chpasswd

grep -rlF 'ssh_pwauth' /etc/cloud 2>/dev/null | xargs -r sed -i -E 's@^[[:space:]]*ssh_pwauth:.*@ssh_pwauth: true@' || true

set_sshd_config PasswordAuthentication yes
set_sshd_config PermitRootLogin yes
set_sshd_config UsePAM yes

sshd -t
systemctl restart sshd
