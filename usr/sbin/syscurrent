#!/bin/bash

main() {
	local dev=$(cat /proc/cmdline | sed 's# #\n#g' | grep root=)
	local idx=${dev#root=/dev/mmcblk0p}

	echo $((idx-13))
}

main "$@"
