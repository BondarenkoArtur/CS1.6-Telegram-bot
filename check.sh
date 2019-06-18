#!/bin/bash

script_full_path=$(dirname "$0")

do_check_with_msg() {
    $script_full_path/cs.sh $1 $2 > /tmp/msg && echo "1" > "/tmp/$1_$2_status" && echo "Sending message to tg" && $script_full_path/tg_msg
}

do_check_w_o_msg() {
    $script_full_path/cs.sh $1 $2 > /tmp/msg && echo "1" > "/tmp/$1_$2_status"
}

do_status() {
    filename="/tmp/$1_$2_status"
    if [ ! -f $filename ] || [[ $(find "$filename" -mmin +30 -print) ]];
    then
        do_check_with_msg $1 $2
        echo "File $filename not exists or it is older than 30 min"
    else
        do_check_w_o_msg $1 $2
        echo "Seems $filename exists and new"
    fi
    cat /tmp/msg
}

do_status "127.0.0.1" "27015"
