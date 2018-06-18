#!/bin/sh

cfg=/usr/local/etc/haproxy/haproxy.cfg
maxconn=512

grep -q " backend relays" $cfg
if [ $? -ne 0 ]; then
  echo "Updating configuration file..."
  echo "    backend relays" >> $cfg
  for relay in $(env | grep "^RELAY_"); do
    key=$(echo $relay | cut -d= -f1)
    value=$(echo $relay | cut -d= -f2)
    name=$(echo $value | cut -d: -f1)
    echo "        server $name $value maxconn $maxconn" >> $cfg
  done
  echo "    backend backends" >> $cfg
  for backend in $(env | grep "^BACKEND_"); do
    key=$(echo $backend | cut -d= -f1)
    value=$(echo $backend | cut -d= -f2)
    name=$(echo $value | cut -d: -f1)
    port=$(echo $value | cut -d: -f2)
    if [ -z "$port" ]; then port=8086 ; fi
    echo "        server $name $name:$port maxconn $maxconn" >> $cfg
  done
  echo "    backend ui-backends" >> $cfg
  for backend in $(env | grep "^BACKEND_"); do
    key=$(echo $backend | cut -d= -f1)
    value=$(echo $backend | cut -d= -f2)
    name=$(echo $value | cut -d: -f1)
    port=$(echo $value | cut -d: -f3)
    if [ -z "$port" ]; then port=8083 ; fi
    echo "        server $name $name:$port maxconn $maxconn" >> $cfg
  done
echo "done"
else
  echo "Configuration already set"
fi
cat $cfg

exec "$(which haproxy)" -p /run/haproxy.pid -f $cfg "$@"

while sleep 60; do
  ps aux |grep haproxy |grep -q -v grep
  PROCESS_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_STATUS -ne 0 - ]; then
    echo "haproxy processes has already exited."
    exit 1
  fi
done