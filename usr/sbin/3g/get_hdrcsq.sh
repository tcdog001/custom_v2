#!/bin/bash

. /usr/sbin/3g/get_3ginfo.in
#. /tmp/get_3ginfo.in
path_3g=/tmp/3g
#
# get the 3g signal stringth , the interval is 10s
# delete the old data in the file of 3g signal strength
#
main() {
        while :
        do
                sleep 10
                local hdrcsq=$(report_hdrcsq)
                local hdrcsq_file=${path_3g}/hdrcsq
                local line=$( grep -n "" ${hdrcsq_file} |wc -l )
                local del_line=$(awk 'BEGIN{printf("%d",'${line}'-'5')}')

                echo ${hdrcsq} >> ${hdrcsq_file}
                fsync ${hdrcsq_file}

                if [[ ${line} -gt 5 ]];then
                        sed -e "1,${del_line}"d ${hdrcsq_file} -i 2>/dev/null
                fi
        done
}

main "$@"
