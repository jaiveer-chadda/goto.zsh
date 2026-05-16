#!/usr/bin/env zsh

unalias g &>/dev/null || :
alias g=goto

# ——————————————————————————————————————————————————————————————————————————— #
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

function goto::error() {
  local -r reset=$'\e[m' lblue=$'\e[94m' red=$'\e[31m'
  local -r sbt="$lblue\`" rbt="\`$reset"

  local -r error="${red}goto$reset: "
  local -r input_hl="$sbt$input$rbt"

  echo -n "$error $input_hl "

  case "$1" {
    ( input ) echo 'must give an input.'                    ;;
    ( found ) echo 'not found.'                             ;;
    ( nodef ) echo "$func_path, i.e. not defined in a file" ;;

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
  }
}

# ——————————————————————————————————————————————————————————————————————————— #
# ——————————————————————————————————————————————————————————————————————————— #

function goto::directory() {
  # if `$input` is a directory, `goto` acts pretty much exactly like `cd`
  target="$input"
}

# ——————————————————————————————————————————————————————————————————————————— #

function goto::file() {
  # `:a` - resolve `./` and `../`
  # `:h` - get the [h]ead of the file (eqv. to `dirname(1)`)
  target="$input:a:h"
}

# ——————————————————————————————————————————————————————————————————————————— #

function goto::command() {
  # this'll output smth like `func is a shell function from /path/to/func.zsh`
  local -H func_path="$( whence -v "$input" 2>/dev/null )"

  # if the path doesn't have a slash in it, it's not a path
  #  (in this case, the function is usually `an autoload shell function`)
  if (( ${#func_path/\/} == $#func_path )) { goto::error nodef; return 1; }

  # strip everything until the first `/` (where the path starts)
  # then add the `/` back
  func_path="/${func_path#*/}"
  target="$func_path:h"  # then get the get the [h]ead of the file
}

# ——————————————————————————————————————————————————————————————————————————— #
# ——————————————————————————————————————————————————————————————————————————— #

# -q : no stdout
# -Q : no stdout/stderr
# -i : interactive

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

  if     [[ -d "$input" ]] { goto::directory
  } elif [[ -e "$input" ]] { goto::file
  } else {

    local type="$( type -w "$input" )"  # outputs smth like `ls: command`
    type="${type##*: }"  # delete until the last colon, leaving `command`

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

# ——————————————————————————————————————————————————————————————————————————— #

# spell:ignore nodef
