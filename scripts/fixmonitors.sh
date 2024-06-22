#!/bin/bash

# Place this in /usr/local/bin
# Configure display manager to run this script on startup

xrandr --output DP-0 --primary --left-of HDMI-0
sudo xrandr --output DP-0 --pos 0x180
