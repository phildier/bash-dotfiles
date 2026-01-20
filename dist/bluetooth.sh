#!/usr/bin/env bash
#
# Bluetooth status and control scripts

btconnect() {
  device=$1
  if [ -z "$device" ]; then
    echo "Usage: btconnect <device_mac_address>"
    return 1
  fi
}
