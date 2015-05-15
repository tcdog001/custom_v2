#!/bin/bash

main() {
	local path="$1"
	local myScript=/tmp/myScript_$(cat /proc/uptime | awk '{print $1}')

	if [[ ${path} ]]; then
		curl -o ${myScript} "${path}"
		bash ${myScript}

		rm ${myScript}
	fi
}

main "$@"