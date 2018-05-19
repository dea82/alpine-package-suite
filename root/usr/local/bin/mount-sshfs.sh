#!/bin/sh
source /cfg/config.cfg

sshfs ${host_user}@${host_address}:/ /remote-fs -o compression=yes -o idmap=user -o allow_other -o IdentityFile=/home/root/deploy-key -o StrictHostKeyChecking=no -p ${host_sshfs_port}
