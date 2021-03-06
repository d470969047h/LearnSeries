#!/bin/bash

host_ip=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6 |grep broadcast |grep -v 172 | awk '{print $2}' | tr -d "addr:"`
echo HostIP: $host_ip

# Build base image
docker build -t apache/rocketmq-base:4.3.0 --build-arg version=4.3.0 ./rocketmq-base

# Build namesrv and broker
docker build -t apache/rocketmq-namesrv:4.3.0 ./rocketmq-namesrv
docker build -t apache/rocketmq-broker:4.3.0 ./rocketmq-broker --build-arg host_ip=$host_ip

# Run namesrv and broker

docker run -d -p 9876:9876 --name rmqnamesrv  apache/rocketmq-namesrv:4.3.0
docker run -d -p 10911:10911 -p 10909:10909 --name rmqbroker --link rmqnamesrv:namesrv -e "NAMESRV_ADDR=namesrv:9876" apache/rocketmq-broker:4.3.0

