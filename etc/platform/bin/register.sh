#!/bin/sh

. /etc/platform/bin/platform.in

main() {
	local URL_PATH=/etc/platform/conf/platform.json
	local URL_DEFAULT=https://lms1.9797168.com:8443/LMS/lte/

	register_operation  "${URL_PATH}" "${URL_DEFAULT}"
}
main "$@"
