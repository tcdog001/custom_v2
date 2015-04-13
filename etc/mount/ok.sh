#!/bin/bash

rootfs0_ok() {
	mkdir -p /tmp/appkey
	cp -fpR /etc/appkey/* /tmp/appkey/
	echo "copy appkey..."
}

config_ok() {
	local file
	local cfile #cloud config file
	local dfile #default config rule
	local rfile #run config file
	local sfile #source config file

	while read file; do
		cfile="/mnt/flash/config/${file}"
		dfile="/${file}"
		rfile="/tmp/config/${file}"
		sfile=${dfile}

		mkdir -p $(dirname ${rfile})

		if [[ -f "${cfile}" ]]; then
			sfile=${cfile}
		fi

		echo "use ${sfile}"
		cp -f ${sfile} ${rfile}
	done < /etc/config.list
}

data_ok() {

}

main() {
	local dev="$1"
	local dir="$2"

	case ${dir} in
	rootfs0)
		rootfs0_ok
		;;
	config)
		config_ok
		;;
	data)
		data_ok
		;;
	*)
		;;
	esac
}

main "$@"
