#!/bin/bash

if [[ ! -x /tmp/config/nginx ]]; then
	mkdir -p /tmp/config/
	cp -r /usr/local/nginx/conf/ /tmp/config/nginx
fi

if [[ ! -x /tmp/log/nginx/logs ]]; then
	mkdir -p /tmp/log/nginx/logs
fi

if [[ ! -x /tmp/pid/nginx ]]; then
	mkdir -p /tmp/pid/nginx
fi

if [[ ! -x /tmp/lock/nginx ]]; then
	mkdir -p /tmp/lock/nginx
fi
                   
if [[ ! -f /tmp/urllist.conf ]];then
	cp /etc/um/urllist.conf /tmp/
fi

#nginx -p /tmp/log/nginx/ -c /tmp/config/nginx/nginx.conf 2> /dev/null
