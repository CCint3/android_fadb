#!/bin/bash

function Usage() {
  printf '%s Usage:\n' "$0"
  printf '%s [--cmd [adb | fastboot]] [--stat stat] args*\n' "$0"
  printf '  --cmd: used command, default: adb\n'
  printf '    option: [adb | fastboot]'
  printf '  --stat: devices state, default: device\n'
  printf '    option: [device | offline | recovery | fastboot] etc.\n'
  printf '\n'
}

function get_target_stat_serial() {
  cmd=$1
  target_stat=$2
  ret=''
  if [ "$cmd" = "adb" ]; then
    awk_param=("NR>1 {print \$1}")
  elif [ "$cmd" = "fastboot" ]; then
    awk_param=("{print \$1}")
  else
    return 1
  fi
  for dev in $(eval "$cmd devices" | awk "${awk_param[@]}"); do
    current_stat=$(eval "$cmd devices" | grep "$dev" | awk '{print $2}')

    if [ "$current_stat" = "$target_stat" ]; then
      ret=$ret"$dev "
    fi
  done
  echo "$ret"
  return 0
}

args=''
cmd="adb"
dev_stat='device'
until [ $# -eq 0 ]; do
  case $1 in
  --stat)
    dev_stat=$2
    shift 2
    ;;
  --cmd)
    cmd=$2
    shift 2
    ;;
  --help)
    Usage
    exit 0
    ;;
  *)
    args=("${args[@]}" "$1")
    shift
    ;;
  esac
done

echo "applying \"$cmd\" command to devices in the \"$dev_stat\" state:"

for dev in $(get_target_stat_serial "$cmd" "$dev_stat"); do
  echo "  applying on: $dev"
  command="$cmd -s $dev ${args[*]}"
  /bin/bash -c "$command" &
done

sleep 1
