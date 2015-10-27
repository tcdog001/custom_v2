#!/bin/sh

. /etc/platform/bin/platform.in

main() {
	local URL=$(get_sysinfo login.url | jq -j '.url')
	local URL_DEFAULT=https://lms1.autelan.com:8143/LMS/lte/

	register_operation_v2  "${URL}" "${URL_DEFAULT}"
}
main "$@"
