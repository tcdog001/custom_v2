#!/bin/bash

#fsck
#
#The exit code returned by fsck is the sum of the following conditions:
#0 - No errors
#1 - File system errors corrected
#2 - System should be rebooted
#4 - File system errors left uncorrected
#8 - Operational error
#16 - Usage or syntax error
#32 - Fsck canceled by user request
#128 - Shared library error
#The exit code returned when multiple file systems are checked is the bit-wise OR of the exit codes for each file system that is checked.
fsck_error() {
	local err=$1

	case ${err} in
	1|4|8)
		echo ${err}
		;;
	*)
		echo 0
		;;
	esac
}

# mount
#
#0:success
#1 - incorrect invocation or permissions
#2 - system error (out of memory, cannot fork, no more loop devices)
#4 - internal mount bug
#8 - user interrupt
#16 - problems writing or locking /etc/mtab
#32 - mount failure
#64 - some mount succeeded
mount_error() {
	local err=$1

	case ${err} in
	8)
		echo ${err}
		;;
	*)
		echo 0
		;;
	esac
}

do_fsck() {
	local dev="$1"

	fsck.ext4 -p ${dev}; err=$?; err=$(fsck_error ${err})
	if ((0!=err)); then
		echo "fsck ${dev} error:${err}"
		mkfs.ext4 -c ${dev}
	fi
}

main() {
	local dev="$1"
	local dir="$2"
	local check="$3"
	local ro="$4"
	local repair="$5"
	local err=0
	local have_mkfs

	if [[ "yes" == "check" ]]; then
		have_mkfs=$(do_fsck ${dev})
	fi

	/etc/mount/pre.sh ${dev} ${dir}
	
	mount -t ext4 -o ${ro},noatime,nodiratime ${dev} ${dir}; err=$?; err=$(mount_error ${err})
	if ((0==err)); then
		/etc/mount/ok.sh ${dev} ${dir}
	elif [[ "no" == ${repair} || -n "${have_mkfs}" ]]; then
		/etc/mount/error.sh ${dev} ${dir}
	fi
}

main "$@"
