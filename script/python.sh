#!/bin/bash
set -euox pipefail

dnf install -y --setopt=install_weak_deps=False python3
curl -LsSf https://astral.sh/uv/install.sh | sh
