#!/bin/bash

. /usr/sbin/3g/get_3ginfo.in
#. /tmp/get_3ginfo.in
main() {
        local imsi=""
        local company_3g=""
        local meid=""
        local iccid=""
        local net_3g=""
        local apn=""

        imsi=$(report_imsi_of3g)
        company_3g=$(report_company_of3g)

        while :
        do
                meid=$(report_meid_of3g)
                [[ ${meid} ]] && break
                sleep 1
        done

        while :
        do
                iccid=$(report_sim_iccid)
                [[ ${iccid} ]] && break
                sleep 1
        done
        net_3g=$(report_net_3g)
        apn=$(get_apn)
}

main "$@"
