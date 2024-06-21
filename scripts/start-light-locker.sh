#!/bin/bash

while true; do
    light-locker --lock-on-suspend --lock-on-lid &
    PID=$!
    wait $PID
    echo "light-locker exited with status $?. Restarting..."
done

