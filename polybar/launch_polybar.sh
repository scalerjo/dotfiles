#!/bin/bash


if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --config=~/.config/polybar/polybar.config --reload toph &
  done
else
  polybar --config=~/.config/polybar/polybar.config --reload toph &
fi
