#!/bin/bash
. /etc/utils/dir.in

set_tmp_log_dir() {
    local dir

    for dir in ${!dir_tmp_log_*}; do
        mkdir -p ${!dir}
    done
}

main() {
	set_tmp_log_dir
	mkdir -p ${dir_opt_log_onoff}
	mkdir -p ${dir_opt_log_drop_3g}
#	mkdir -p ${dir_config}
	mkdir -p /tmp/config
}
main "$@"
