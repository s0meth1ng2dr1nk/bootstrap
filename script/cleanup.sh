#!/bin/bash
set -euox pipefail

dnf clean all
rm -rf /var/cache/dnf/* /var/cache/yum/*
