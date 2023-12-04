# From dhcpcd
# Write a syslog entry
syslog()
{
        local lvl="$1"

        if [ "$lvl" = debug ]; then
                [ -n "${syslog_debug:-}" ] || return 0
        fi
        [ -n "$lvl" ] && shift
        [ -n "$*" ] || return 0
        #case "$lvl" in
        #err|error)	echo "$interface: $*" >&2;;
        #*)		echo "$interface: $*";;
        #esac
        #TODO pid comes automatically or is this about ppid?
        if type logger >/dev/null 2>&1; then
          #TODO journal does not show --id
          logger "--id=$$" -p "${syslog_facility:-user}"."$lvl" -t "${syslog_name:-"$(basename "$0")"}" "$*"
        else
          "${lvl}_sd" "$*"
        fi
}

fatal_sd() {
  printf "<2>%s\n" "$*" >&2
}

error_sd() {
  printf "<3>%s\n" "$*" >&2
}

warn_sd() {
  printf "<4>%s\n" "$*" >&2
}

notice_sd() {
  printf "<5>%s\n" "$*"
}

info_sd() {
  printf "<6>%s\n" "$*"
}

debug_sd() {
  printf "<7>%s\n" "$*"
}

warn() {
  printf "%s: %s\n" "$(basename "$0")" "$*" >&2
}

fail() {
  #if [ -n "${BASH_LINENO:-}" ]; then
    #warn "line ${BASH_LINENO[1]}: $*" >&2
  #else
    warn "$*" >&2
  #fi
  exit 1
}
