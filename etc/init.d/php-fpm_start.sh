#!/bin/bash

if [[ ! -f /tmp/config/php/php-fpm.ini ]]; then
	mkdir -p /tmp/config/
	cp -r /usr/local/php/ /tmp/config/php
fi

#php-fpm -y /tmp/config/php/php-fpm.ini 2> /dev/null
