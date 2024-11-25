#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 SSID"
    exit 1
fi

nmcli dev wifi connect $1 --ask
