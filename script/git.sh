#!/bin/bash
set -euo pipefail

BASE=$(cd $(dirname "${BASH_SOURCE[0]:-0}") && pwd -P)
cd "${BASE}"
source common.env
source secret.env

curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash
dnf install -y --setopt=install_weak_deps=False git-lfs
git lfs install --system
git config --global core.autocrlf false
git config --global core.symlinks true
git config --global credential.helper store
echo "https://${GIT_USER}:${GIT_PAT}@github.com" > "${HOME}/.git-credentials"
