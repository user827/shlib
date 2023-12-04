# allows to see errors with -e even when this function is not used
geterr() {
  _err=0
  "$@" || _err=$?
}
