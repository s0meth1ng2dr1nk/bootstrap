#!/bin/bash

sed -i -E 's@^SELINUX=.*@SELINUX=disabled@' /etc/selinux/config
setenforce 0
