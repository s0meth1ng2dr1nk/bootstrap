#!/bin/bash
set -euo pipefail

rm -rf /opt/skill/i-have-adhd
curl -fsSL https://github.com/ayghri/i-have-adhd/archive/refs/heads/main.tar.gz | tar -xz -C /opt/skill
mv -f /opt/skill/i-have-adhd-main /opt/skill/i-have-adhd
