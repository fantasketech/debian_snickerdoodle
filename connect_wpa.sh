#!/bin/bash

case "$2" in
    CONNECTED)
        /sbin/dhclient -nw wlan0;
        ;;
    DISCONNECTED)
        killall dhclient;
        ;;
	*)
		killall dhclient;
		;;
esac
