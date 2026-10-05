#!/bin/bash
set -euox pipefail

rm -rf /opt/skill/i-have-adhd
git clone -b main https://github.com/ayghri/i-have-adhd.git /opt/skill/i-have-adhd
