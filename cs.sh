#!/bin/bash

IP=$1 
PORT=$2

do_check(){
    printf $'\xff\xff\xff\xff\x54\x53\x6f\x75\x72\x63\x65\x20\x45\x6e\x67\x69\x6e\x65\x20\x51\x75\x65\x72\x79\x00' > /tmp/req
    printf $'\xFF\xFF\xFF\xFF\x55\xFF\xFF\xFF\xFF' > /tmp/req1
    (cat /tmp/req; sleep 1; cat /tmp/req1; sleep 1; echo ^C) | netcat -uc $IP $PORT > /tmp/resp
    if [ -s /tmp/resp ]
    then
        HEX=$(cat /tmp/resp | hexdump -ve '1/1 "%.2x "')
        HEXINFO=$(echo $HEX | grep -o '00 0a 00 .. .. ..')
        PLAYERS=$(echo $HEXINFO | cut -d' ' -f 4)
        MAX=$(echo $HEXINFO | cut -d' ' -f 5)
        BOTS=$(echo $HEXINFO | cut -d' ' -f 6)

        MAP=$(cat /tmp/resp | strings | sed -n 2p)

        echo "<code>connect $IP:$PORT</code>"
        echo Current map: $MAP

        echo Players: $((16#$PLAYERS))/$((16#$MAX)) \(bots: $((16#$BOTS))\)
        if [[ $PLAYERS -eq 0 ]] || [ -f $PLAYERS ]
        then
            exit 2
        else
            HEX_CH_NUM=$(echo $HEX | grep -o 'ff ff ff ff 41 .. .. .. ..')
            B1=$(echo $HEX_CH_NUM | cut -d' ' -f 6)
            B2=$(echo $HEX_CH_NUM | cut -d' ' -f 7)
            B3=$(echo $HEX_CH_NUM | cut -d' ' -f 8)
            B4=$(echo $HEX_CH_NUM | cut -d' ' -f 9)
            printf "\xFF\xFF\xFF\xFF\x55\x$B1\x$B2\x$B3\x$B4" > /tmp/valve_channel_number
            (cat /tmp/valve_channel_number; sleep 1; echo ^C) | netcat -uc $IP $PORT > /tmp/resp_second
            strings /tmp/resp_second 
            exit 0
        fi
    else 
        echo Probably $IP:$PORT is not responding
        exit 1
    fi
}

if [ -z $1 ] || [ -z $2 ];
then 
    echo "Usage $0 [ip] [port]"
else
    do_check $1 $2
fi
