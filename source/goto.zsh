#!/usr/bin/env zsh

function goto() {
  setopt local_options warn_create_global

  # concatenate the input with `$IFS`, so an unquoted input like
  #  `/path to/some dir` will be read as one argument: `"/path to/some dir"`
  local IFS=$' \t\n\0'
  # note: `-H` is used on vars containing paths, to hide them from `abbrpath`
  local -rH input="${*:-"$OLDPWD"}"

  # ———————————————————————————————————————————————————————————————————————— #

  # if no input was passed, and `$OLDPWD` is unset/empty, then exit
  #  and blame it on on the user for not passing an input
  if [[ -z "$input" ]] echo "$no_input" >&2 && return 1

  # ———————————————————————————————————————————————————————————————————————— #

  local -H target=  # will be set by one of the sub-functions

  if     [[ -d "$input" ]] { goto::directory # dir  - just act like `cd`
  } elif [[ -e "$input" ]] { goto::file      # file - go to the file's dir
  } else {

    local type="$( type -w "$input" )"  # outputs smth like `ls: command`
    type="${type##*: }"  # delete until the last colon, leaving just `command`

    case "$type" {
      ( command | function ) goto::command ;;
      ( none ) goto::error found; return 1 ;;
      ( *    ) goto::error types; return 2 ;;
    }
  }

  # if any of the `goto::...` functions fail, return their exit codes
  #  they print their own error messages, so this main function doesn't have to
  local -ri 10 exit_code=$?
  if (( exit_code )) return exit_code

  # ———————————————————————————————————————————————————————————————————————— #

  ls "$target" &>/dev/null || { goto::error perms; return 1; }

  # if `cd` succeeds, print the command that's about to be run
  abbrpath -C cd "$target" >&2
}
