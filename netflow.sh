#!/bin/bash

set -xv

eth_in_old=$(ifconfig eth0|grep "RX bytes"|sed 's/RX bytes://'|awk '{print $1}')
eth_out_old=$(ifconfig eth0|grep "RX bytes"|sed 's/.*TX bytes://'|awk '{print $1}')
ip=$(ifconfig eth0|grep "inet addr"|sed 's/^.*addr://g'|awk '{print $1}')

sleep 1

while true; do
        eth_in_new=$(ifconfig eth0|grep "RX bytes"|sed 's/RX bytes://'|awk '{print $1}')
        eth_out_new=$(ifconfig eth0|grep "RX bytes"|sed 's/.*TX bytes://'|awk '{print $1}')
        eth_in=$(echo "scale=2;($eth_in_new - $eth_in_old)/1000.0"|bc|awk '{printf "%.2f", $0}')
        eth_out=$(echo "scale=2;($eth_out_new - $eth_out_old)/1000"|bc| awk '{printf "%.2f", $0}')
        echo "IN: $eth_in KB"
        echo "OUT:$eth_out KB"
        sleep 1
	if `echo $eth_in | awk -v tem=1 '{print($1>tem)? "true":"fales"}'`||`echo $eth_out | awk -v tem=1 '{print($1>tem)? "true":"fales"}'`; then
		curl 'https://oapi.dingtalk.com/robot/send?access_token=xxxxxxx' \
   		-H 'Content-Type: application/json' \
   		-d '
  			{"msgtype": "text",
    				"text": {
        				"content": "IN:'"$eth_in"'KB/s, OUT:'"$eth_out"'KB/s, IP:'"$ip"'"
   					  }
  			}'
	fi
done
