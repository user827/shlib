# 0 both user and group not created
# 1 user or group created
user_group_notcreated() {
  local user=$1 uid=$2 group=$3 gid=$4
  group_exists "$group" "$gid"
  if [ "$_RET" = 1 ]; then
    user_exists "$user" "$uid"
    if [ "$_RET" = 1 ]; then
      return 0
    else
      echo "error: group '$group' does not exists but user '$user' does"
      return 1
    fi
  fi
  user_exists "$user" "$uid"
  if [ "$_RET" = 1 ]; then
    echo "error: group '$group' exists but user '$user' does not"
  fi
  return 1
}

remove_user_group() {
  local user=$1 uid=$2 group=$3 gid=$4
  user_exists "$user" "$uid"
  if [ "$_RET" = 0 ]; then
    group_exists "$group" "$gid"
    if [ "$_RET" = 0 ]; then
      echo Removing "$user" user
      userdel "$user"
      echo Removing "$group" group
      groupdel "$group"
    else
      echo "warning: group '$group' not correctly set: not removing"
    fi
  else
    echo "warning: user '$user' not correctly set: not removing"
  fi
}

group_exists() {
  _ent_exists group "$@"
}

user_exists() {
  _ent_exists passwd "$@"
}

_ent_exists() {
  local namee "name=$2" "id=$3" ide id_exists=n name_exists=n
  if ide=$(getent "$1" "$id"); then
    id_exists=y
  fi
  if namee=$(getent "$1" "$name"); then
    name_exists=y
  fi
  if [ "$id_exists" = y ] || [ "$name_exists" = y ]; then
    if [ "$namee" != "$ide" ]; then
      echo "error: $1 id '$id' or name '$name' exists but does not match the other"
      _RET=2
      return
    fi
    _RET=0
    return
  fi
  _RET=1
  return
}
