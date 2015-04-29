#!/bin/bash

. /usr/sbin/3g/check_3gdown_result.sh
. /usr/sbin/3g/common_opera.in
#. /tmp/check_3gdown_result.sh
#. /tmp/common_opera.in

path_3g=/tmp/3g
state_file=/tmp/3g/3g_state.log
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
                        echo "${ret}" >${state_file}
                        add_route
                        dns_resolve
                        break
                else
                        ((j++))
                        if [[ $j -eq 2 ]];then
                                echo "${ret}" >${state_file}
                                logger -t $0 "ping ${ping_addr} ERROR, ret=${ret} !"
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
                echo "1" >${state_file}
                logger -t $0 "dns resolve 163 and baidu ERROR !"
        else
                echo "0" >${state_file}
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
                        echo "1" >${state_file}
                        logger -t $0 "interface ppp0 do not have IP address!"
                else
                        ping_net
                fi
        else
                echo "${ret_inter}" >${state_file}
                logger -t $0 "Do not have interface ppp0 !"
        fi
}

main () {
        local num=0
        while :
        do
                check_ppp0
                local state=$(cat ${state_file} 2>/dev/null)
                local starttime_file=${path_3g}/starttime
                local starttime=$(cat ${starttime_file} 2>/dev/null)
                if [[ ${state} -eq 0 ]];then
                        num=0
                        if [[ -z ${starttime} ]];then
                                starttime=$(get_now_time)
                                echo ${starttime} >${starttime_file}
                        fi
                        #sysled 3g on
                else
                        num=$(($num+1))
                        #sysled 3g off
                        if [[ ${num} -ge 9 ]];then
                                logger -t $0 "The network is unreachable, start to check the result !"
                                drop_3g_log
                                start_check
                                num=0
                        fi
                fi
                sleep 10
        done
}

main "$@"
