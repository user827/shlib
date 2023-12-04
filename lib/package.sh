unz() {
  local src="$1" dstdir="$2"
  case "$src" in
    *.lrz)
      lrzuntar -O "$dstdir" "$src"
      ;;
    *.zst)
      unzstd "$src" --stdout | tar -x -C "$dstdir"
      ;;
    *)
      tar -xaf "$src" -C "$dstdir"
      ;;
  esac
}

