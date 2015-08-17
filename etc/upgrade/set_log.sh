#!/bin/bash

. ${__ROOTFS__}/etc/utils/dir.in
. ${__ROOTFS__}/etc/utils/utils.in

save_log() {

	local now=$(getnow)
	local file=${dir_tmp_log_sys_md_init}/md_init-${now}
	#
	# save md init info
	#
	dmesg > ${file}; fsync ${file}

	#
	# save md syslog
	#
	file=${dir_tmp_log_sys_md_ulog}/md_ulog-${now}; touch ${file}
	#
	# for readsyslog
	#
	LN_FILE ${file} ${file_md_ulog}
	#
	# start syslogd, log at rootfs_data
	#	Max size (1024KB) before rotate
	#
	syslogd -s 1024 -O ${file}
	#
	# todo: how to save /proc/kmsg
	#	#

}

main() {
	save_log
}

main "$@"
