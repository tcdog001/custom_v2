#!/bin/bash

. /usr/sbin/check_3gdown_result.in
. /usr/sbin/common_opera.in
. /etc/utils/utils.in

path_3g=/tmp/.3g
path_data_3g=/data/3g
state_file=/tmp/.3g/3g_state.log
sign_3g_state=0

write_jlog() {
        local info=$1
        jwaring_kvs 3g  \
                inter 'ppp0'    \
                waring ${info}   \
                #end
}
#
# record the state of 3g
# 0: 3g connect
# 1: 3g disconnect
#
write_state() {
        local old_state=$(cat ${state_file} 2>/dev/null)
        local time=$(get_now_time)
        local ontime=${path_3g}/ontime
        local offtime=${path_3g}/offtime
        local new_state=$1
        local info=$2
         
        if [[ ${new_state} -eq 1 ]];then
                if [[ ${sign_3g_state} -eq 0 ]];then
                        write_jlog ${info}
                        sign_3g_state=1
                fi
        else
                sign_3g_state=0
        fi
        if [[ ${new_state} != ${old_state} ]];then
                echo ${new_state} > ${state_file}
                if [[ ${new_state} -eq 0 ]];then
			ntpclient -h cn.pool.ntp.org -s -c 1 && \
				ntpclient -h cn.pool.ntp.org -s -c 1
			echo ${time} > ${ontime}
#                        syn_net_time
                else
                        if [[ ${old_state} -eq 0 ]];then
                                echo ${time} > ${offtime}
                        fi
                fi
        fi
}
#
# write the info that can dial to data/3g
# $1:file_name: meid imsi sn iccid net apn tel company 3g_model ...
#
diff_data_tmp() {
        local file_name=$1
        local tmp_info=$(cat ${path_3g}/${file_name} 2>/dev/null)
        local data_info=$(cat ${path_data_3g}/${file_name} 2>/dev/null)
        if [[ ${tmp_info} != ${data_info} ]];then
                echo ${tmp_info} > ${path_data_3g}/${file_name}; fsync ${path_data_3g}/${file_name}
        fi
}
write_data() {
        diff_data_tmp "meid"
        diff_data_tmp "imsi"
        diff_data_tmp "sn"
        diff_data_tmp "iccid"
        diff_data_tmp "net"
        diff_data_tmp "apn"
        diff_data_tmp "tel"
        diff_data_tmp "company"
        diff_data_tmp "3g_model"
}
#
# record the log of 3g drop (30min)
#
record_log() {
        local time=$(get_now_time)
        local startup=$(cat /tmp/.startup 2>/dev/null)
        local ontime=$(check_file "${path_3g}/ontime" "null" 2>/dev/null)
        local offtime=$(check_file "${path_3g}/offtime" "null" 2>/dev/null)
        local duration=$1
        local log_file=${path_3g}/3g_offline_${startup}.log

        printf '{"time":"%s", "ontime":"%s", "offtime":"%s", "duration":"%s"}\n'    \
                "${time}"       \
                "${ontime}"     \
                "${offtime}"    \
                "${duration}"   >> ${log_file}
}
#
# ping IP(114.114.114.114)
# if ping is OK, add route & check dns
#
ping_net() {
        local ping_addr=114.114.114.114

        local j=0

        while(( $j < 3 ))
        do
                ping ${ping_addr} -w 2 -q >/dev/null 2>&1 ; local ret=$?
                if [[ ${ret} -eq 0 ]];then
                        write_state "${ret}"
                        dns_resolve
                        break
                else
                        ((j++))
                        if [[ $j -eq 2 ]];then
                                write_state "${ret}" "ping_fail"
                        fi
                fi
        done
}
#
# check dns resolve, 163 & baidu
#
dns_resolve() {
        nslookup www.163.com  >/dev/null 2>&1; local ret_163=$?
        nslookup www.baidu.com  >/dev/null 2>&1; local ret_baidu=$?

        if [[ ${ret_163} -ne 0 && ${ret_baidu} -ne 0 ]];then
                write_state "1" "dns_fail"
        else
                write_state "0"
        fi
}
#
# check ppp0 IP
#
get_ppp0_ip(){
        local ppp0_ip=$(ifconfig ppp0 |awk '/inet addr/{print $2}' |awk -F ':' '{print $2}' 2>/dev/null)
        echo ${ppp0_ip}
        local endtime=$(get_now_time)
        echo ${endtime} >${path_3g}/endtime
        get_3gup_flow
        get_3gdown_flow
}
check_ppp0() {
        ifconfig ppp0 >/dev/null 2>&1; local ret_inter=$?
        if [[ ${ret_inter} -eq 0 ]];then
                local ppp_ip=$(get_ppp0_ip)
                if [[ -z ${ppp_ip} ]];then
                        write_state "1" "noip"
                else
                        write_data
                        ping_net
                fi
        else
                write_state "${ret_inter}" "nointer"
        fi
}

main () {
        local num=0
        local interval=$(get_confinfo "3g.conf.get_3g_state.interval" 2>/dev/null)
        if [[ -z ${interval} ]];then
                interval=10
        fi
        while :
        do
        	sleep ${interval}
		check_ppp0
                local state=$(cat ${state_file} 2>/dev/null)
                local starttime_file=${path_3g}/starttime
                local starttime=$(cat ${starttime_file} 2>/dev/null)
                if [[ ${state} -eq 0 ]];then
                        num=0
                        led_3g_on
			if [[ -z ${starttime} ]];then
                                starttime=$(get_now_time)
                                echo ${starttime} >${starttime_file}
                        fi
                else
                        num=$(($num+1))
                        led_3g_off
                        local num2=$((${num} % 9))
                        if [[ ${num} -gt 180 ]];then
                                local duration=$((${num} * 30))
                                record_log "${duration}"
                                start_check
                                num=0
                        else
                                if [[ ${num2} -eq 0 ]];then
                                        drop_3g_log
                                        start_check
                                fi
                        fi
                fi
        done
}

main "$@"
