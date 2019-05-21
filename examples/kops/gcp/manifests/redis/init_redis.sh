#!/bin/bash

echo 'hello'

for i in {1..100}
do
    if ps -ef | grep -v "grep" | grep redis-server
    then
        break
    else
        echo >&1 'Redis init process in progress...'
        sleep 3
    fi
done

if [ "$i" == 100 ]; then
    echo >&2 'Redis init process failed.'
    exit 1
fi

sleep 10

cat /data.txt | redis-cli --pipe