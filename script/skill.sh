#!/bin/bash
set -euox pipefail

rm -rf /opt/skill/i-have-adhd
git clone -b main --depth 1 https://github.com/ayghri/i-have-adhd.git /opt/skill/i-have-adhd
