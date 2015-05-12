#!/bin/bash

if [[ ! -x /tmp/config/ssh ]]; then
	cp -r /usr/local/ssh/conf/ /tmp/config/ssh
	chmod 600 /tmp/config/ssh/ssh_host_rsa_key
fi

/usr/sbin/sshd -f /tmp/config/ssh/sshd_config -h /tmp/config/ssh/ssh_host_rsa_key -p 22 &
