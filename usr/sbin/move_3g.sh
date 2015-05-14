#!/bin/bash

. /etc/utils/dir.in

move_file() {
        local file_path=$1
        local file_name=$2

        if [[ ! -f ${dir_opt_log_drop_3g} ]];then
                mkdir ${dir_opt_log_drop} 2>/dev/null
                mkdir ${dir_opt_log_drop_3g} 2>/dev/null
        fi 

        cp ${file_path}/${file_name} ${dir_opt_log_drop_3g} 2>/dev/null;local ret=$?
        fsync ${dir_opt_log_drop_3g}

        if [[ ${ret} -ne 0 ]];then
                echo "MOVE 3G: NOK !"
        else
                return 1
        fi
}

do_server() {
        local tmp_path=$1
        local tmp_file=$2

        ls -la ${tmp_path}/${tmp_file} >/dev/null 2>&1; local ret=$?
        if [[ ${ret} -eq 0 ]];then
                diff ${tmp_path}/${tmp_file} ${dir_opt_log_drop_3g}/${tmp_file} >/dev/null 2>&1;local ret_diff=$?
                if [[ ${ret_diff} -ne 0 ]];then
                        move_file "${tmp_path}" "${tmp_file}"
                else
                        return 1
                fi
        else
                logger -t $0 "${tmp_path}/${tmp_file} do not exist !"
                return 1
        fi
}

main() {
        while :
        do
                do_server "${dir_tmp_log_drop_3g}" "3g_drop_*" ;local ret1=$?
                do_server "/tmp/.3g" "3g_offline_*" ;local ret2=$?

                if [[ ${ret1} -eq 1 && ${ret2} -eq 1 ]];then
                        break
                fi
        done
}
main "$@"
