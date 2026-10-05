#!/bin/bash
set -euox pipefail

dnf update -y --setopt=install_weak_deps=False --exclude='kernel*'
