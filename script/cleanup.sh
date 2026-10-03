#!/bin/bash
set -euo pipefail

dnf clean all
rm -rf /var/cache/dnf/* /var/cache/yum/*
