#!/bin/bash

function Usage() {
  printf '%s Usage:\n' "$0"
  printf '  --fastboot: use fastboot command, default: adb\n'
  printf '  --stat: devices state, default: device\n'
  printf '    option: [device | offline | recovery | fastboot] etc.\n'
  printf '\n'
}

args=''
is_fastboot='false'
dev_stat='device'
until [ $# -eq 0 ]; do
  case $1 in
  --stat)
    dev_stat=$2
    shift 2
    ;;
  --fastboot)
    is_fastboot='true'
    shift 1
    ;;
  --help)
    Usage
    exit 0
    ;;
  *)
    args="$args $1"
    shift
    ;;
  esac
done

if [ "$is_fastboot" == "true" ]; then
  base_cmd="fastboot"
else
  base_cmd="adb"
fi
echo "applying \"$base_cmd\" command to devices in the \"$dev_stat\" state:"

OLD_IFS=$IFS
IFS=$'\x0a'
devices_cmd="$base_cmd devices"
for i in $(eval "$devices_cmd" | awk 'NR>1 {print $0}'); do
  IFS=$OLD_IFS
  dev=$(echo "$i" | awk -F " " '{print $1}')
  stat=$(echo "$i" | awk -F " " '{print $2}')
  if [ "$stat" == "$dev_stat" ]; then
    echo "  applying: $i"
    command="$base_cmd -s $dev $args"
    eval "$command"
  else
    echo "  skipping: $i"
  fi
  IFS=$'\x0a'
done
IFS=$OLD_IFS
