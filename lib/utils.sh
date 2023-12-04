waitpid() {
    _RET=0
    local pid="$1" name="$2"
    wait "$pid" 2> /dev/null || _RET=$?
    while [ "$_RET" -ge 128 ]; do
      log notice "$name wait returned $_RET"
      wait "$pid" 2> /dev/null || _RET=$?
    done
    if [ "$_RET" -ne 0 ]; then
      log error "$name wait returned $_RET"
    fi
}

_get_spec_from_pid() {
  local p="$1" js="$2" spec pid rest
  if [ -n "$BASH" ]; then
    printf "%s\n" "$js" | while read -r spec pid status rest; do
      if [ "$p" = "$pid" ] && [ "$status" = Running ]; then
        spec="${spec#?}"
        spec="${spec%?}"
        spec="${spec%]}"
        printf "%s\n" "$spec"
        break
      fi
    done
  else
    printf "%s\n" "$js" | sed -r 's/\[([^]])\][^0-9]+([0-9]+)([^0-9].*)/\1 \2 \3/' | while read -r spec pid status rest; do
      if [ "$p" = "$pid" ] && [ "$status" = Running ]; then
        printf "%s\n" "$spec"
        break
      fi
    done
  fi
}
get_spec_from_pid() {
  local p="$1" js
  if [ -n "$BASH" ]; then
    js=$(jobs -l)
  else
    local tmp
    tmp=$(mktemp)
    jobs -l > "$tmp"
    js=$(cat "$tmp")
    rm "$tmp"
  fi
  _RET=$(_get_spec_from_pid "$p" "$js")
}

# prevent killing processes that have the same pid but are different
# Bash reaps its children for its own purposes so by the time we send the signal the pid might have
# already been reused by another process.
kill_if_not_reaped() {
  local pid="$1" _RET
  get_spec_from_pid "$pid"

  if [ -n "$_RET" ]; then
    kill %"$_RET"
  else
    return 1
  fi
}
