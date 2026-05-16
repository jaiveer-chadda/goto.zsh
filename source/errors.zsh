#!/usr/bin/env zsh

# ——————————————————————————————————————————————————————————————————————————— #

function goto::error() {
  if ! (( show_errors )) return 0

  local -r reset=$'\e[m' lblue=$'\e[94m' red=$'\e[31m'
  local -r sbt="$lblue\`" rbt="\`$reset"

  local -r error="${red}goto$reset: "
  local -r input_hl="$sbt$input$rbt"

  echo -n "$error" >&2

  case "$1" {
    ( input ) echo 'must give an input.'                     ;;
    ( found ) echo "$input_hl not found."                    ;;
    ( opts  ) echo "unknown option: $sbt$2$rbt."             ;;
    ( nodef ) echo "$func_path, i.e. not defined in a file." ;;

    ( types )
      echo 'input must be a path, function, or command.' \
      "$input_hl is $type."
    ;;

    ( perms )
      echo -n "you don't have the permissions to access $target. "

      local owner group
      goto::get_owner "$target" || { echo; return 0; }

      echo "It's owner is $sbt$owner$rbt (group $sbt$group$rbt)"
    ;;
  } >&2
}

# ——————————————————————————————————————————————————————————————————————————— #

function goto::get_owner() {
  local -ri 10 delim=$RANDOM
  local user_info=

  user_info="$(  stat -c "%U$delim%G" "$1" 2>/dev/null )" || \
  user_info="$( gstat -c "%U$delim%G" "$1" 2>/dev/null )" || return 1

  owner="${user_info%$delim*}"
  group="${user_info#*$delim}"
}

# ——————————————————————————————————————————————————————————————————————————— #
