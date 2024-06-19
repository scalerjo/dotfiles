#!/bin/bash

# Check if brightness level is provided as an argument
if [ -z "$1" ]; then
  exit 1
fi

BRIGHTNESS=$1

# Ensure the brightness level is a valid number between 0.0 and 1.0
if ! [[ "$BRIGHTNESS" =~ ^0(\.[0-9]+)?$|^1(\.0)?$ ]]; then
  exit 1
fi

# Get the list of connected displays
DISPLAYS=$(xrandr --query | grep " connected" | awk '{print $1}' | xargs)

# Check if there is atleast 1 display connected
if [ -z "$DISPLAYS" ]; then
  exit 1
fi

# Loop through each display and set the brightness
for DISPLAY in $DISPLAYS; do
  xrandr -display :0.0 --output "$DISPLAY" --brightness "$BRIGHTNESS"
done
