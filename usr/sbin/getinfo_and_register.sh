#!/bin/bash


main() {
	/usr/sbin/wr_product_info 
	sleep 90
	/usr/sbin/wr_hd_info 
	
	/usr/sbin/get_device_info.sh 
	/etc/platform/bin/register.sh &
}
main "$@"
