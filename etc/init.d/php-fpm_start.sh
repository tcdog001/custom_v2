#!/bin/bash

if [[ ! -x /tmp/config/php ]]; then
	cp -r /usr/local/php/ /tmp/config/php
fi

php-fpm -y /tmp/config/php/php-fpm.ini 2> /dev/null
