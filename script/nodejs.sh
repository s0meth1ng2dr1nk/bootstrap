#!/bin/bash
set -euox pipefail

dnf install -y --setopt=install_weak_deps=False nodejs
curl -fsSL https://get.pnpm.io/install.sh | env -u SUDO_USER sh -
