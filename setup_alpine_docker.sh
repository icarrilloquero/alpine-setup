#!/bin/sh

apk add nano
# Uncomment the community repo
nano /etc/apk/repositories

apk update

apk add openvpn py-pip docker

# Config cgroups properly
echo "cgroup /sys/fs/cgroup cgroup defaults 0 0" >> /etc/fstab
cat >> /etc/cgconfig.conf <<EOF
mount {
cpuacct = /cgroup/cpuacct;
memory = /cgroup/memory;
devices = /cgroup/devices;
freezer = /cgroup/freezer;
net_cls = /cgroup/net_cls;
blkio = /cgroup/blkio;
cpuset = /cgroup/cpuset;
cpu = /cgroup/cpu;
}
EOF

# Isolate containers with a user namespace
adduser -SDHs /sbin/nologin dockermap
addgroup -S dockermap
echo dockermap:$(cat /etc/passwd|grep dockermap|cut -d: -f3):65536 >> /etc/subuid
echo dockermap:$(cat /etc/passwd|grep dockermap|cut -d: -f4):65536 >> /etc/subgid

cat >> /etc/docker/daemon.json <<EOF
{  
        "userns-remap": "dockermap"
}
EOF

# Start docker at boot
rcupdate add docker boot
service docker start

pip install docker-compose~=1.23.0

echo
echo "Please reboot the system to apply changes!"
echo
