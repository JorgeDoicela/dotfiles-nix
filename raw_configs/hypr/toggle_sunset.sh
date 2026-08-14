#!/usr/bin/env bash
# Toggles the hyprsunset blue light filter process

if pgrep -x "hyprsunset" > /dev/null; then
    killall hyprsunset
else
    # Start hyprsunset with a comfortable warm color temperature (3500K)
    hyprsunset -t 3500 -g 90 &disown
fi
