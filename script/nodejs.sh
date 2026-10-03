#!/bin/bash
set -euo pipefail

dnf install -y --setopt=install_weak_deps=False nodejs npm
