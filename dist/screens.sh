#!/usr/bin/env bash

mobile() {
  xrandr --output DP-1 --off --output DP-2 --off --output eDP-1 --auto

  if lspci | grep "Radeon HD 8830M" &>/dev/null; then
    switch_modes ati_mobile
  else
    switch_modes dell_mobile
  fi
}

docked() {
  # shellcheck disable=SC2207
  where=${1:-below}
  displays=($(xrandr | awk '$2~/^connected/{print $1}'))
  if [[ ${#displays[@]} -eq 3 ]]; then
    xrandr --output "${displays[0]}" --off --output "${displays[1]}" --auto --output "${displays[2]}" --auto "--$where" "${displays[1]}"
  elif [[ ${#displays[@]} -eq 2 ]]; then
    xrandr --output "${displays[0]}" --auto --output "${displays[1]}" --auto "--$where" "${displays[0]}"
  fi
  pactl set-default-sink "$(pactl list | awk '$1~/Name/ && $2~/output.*KTMicro/{print $2}' | head -n1)"
  pactl set-default-source "$(pactl list | awk '$1~/Name/ && $2~/input.*Yeti/{print $2}')"
}

hdmi() {
  xrandr --output eDP1 --auto --output HDMI1 --auto --same-as eDP1
}
