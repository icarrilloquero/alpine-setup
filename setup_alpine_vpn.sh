#!/bin/sh
apk add openvpn
mkdir /dev/net
mknod /dev/net/tun c 10 200
