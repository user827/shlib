#!/bin/sh

. /usr/lib/shlib/logs.sh

# NOTE needs fdesc 9
lock_path() {
  _RET=
  local "lpath=$1"
  [ -f "$lpath" ] || touch "$lpath"
  exec 9<"$lpath"
  flock -w 1600 9 || return 1
  read -r _RET <&9 || true
  #printf %s\\n $$ | dd status=none conv=fsync of="$lpath"
  printf %s\\n $$ > "$lpath"
}

unlock_path() {
  [ -f "$1" ] || return 1
  rm "$1"
  flock -u 9
  exec 9<&-
  #: > "$1"
}
