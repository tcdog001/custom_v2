#!/bin/sh

. /etc/platform/bin/platform.in

main() {
	local URL_PATH=/etc/platform/conf/platform.json
	local URL_DEFAULT=https://lms1.97971com:68.8443/LMS/lte/

	command_operation  "$URL_PATH" "$URL_DEFAULT"
}
main "$@"
