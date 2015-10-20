#!/bin/sh

. /etc/platform/bin/platform.in

main() {
	local URL_PATH=/etc/platform/conf/platform_v2.json
	local URL_DEFAULT=https://lms1.autelan.com:8143/LMS/lte/

	status_operation_v2  "${URL_PATH}" "${URL_DEFAULT}"
}
main "$@"
