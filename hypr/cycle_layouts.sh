#!/bin/sh

set -e
CURR=$(hyprctl getoption general:layout | head -1 | awk '{print $2}')

if [ $CURR = "dwindle" ]; then
    hyprctl keyword general:layout master
elif [ $CURR = "master" ]; then
    hyprctl keyword general:layout dwindle
fi
