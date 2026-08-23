#!/usr/bin/env bash
# Toggles the hyprsunset blue light filter process

if pgrep -f "hyprsunset" > /dev/null; then
    pkill -f "hyprsunset"
else
    # Start hyprsunset with a comfortable warm color temperature (3500K)
    hyprsunset -t 3500 -g 90 >/dev/null 2>&1 &
fi
