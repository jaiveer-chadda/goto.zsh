#!/usr/bin/env zsh

function goto() {

  setopt local_options
  setopt warn_create_global

  # ———————————————————————————————————————————————————————————————————————— #

  # note: `-H` is used on vars that hold paths, to hide them from `abbrpath`
  local -aH inputs

  local -i 2  chase_links=0 interactive=0
  local -i 2  show_errors=1 show_cd_cmd=1
  # local -i 10 relative_dir=0
  local relative_dir=0

  # send the options off to be parsed
  #  `parse_opts` will set the opts and put the remaining inputs into `$inputs`
  goto::parse_opts "$@" || return $?

  # ———————————————————————————————————————————————————————————————————————— #

  # concatenate the input with spaces, so an unquoted input like
  #  `/path to/some dir` will be read as one argument: `"/path to/some dir"`
  local -H input="${(j: :)inputs}"

  # if no input was passed, or if it's all spaces, exit
  if [[ -z "$relative_dir" && "$input" =~ '^ *$' ]] {
    goto::error input
    return 1
  }

  # ———————————————————————————————————————————————————————————————————————— #

  local -H target=  # will be set by one of the sub-functions

  if    (( relative_dir )) { goto::relative   # -/+N - go fwd/back N dirs
  } elif [[ -d "$input" ]] { goto::directory  # dir  - just act like `cd`
  } elif [[ -e "$input" ]] { goto::file       # file - go to the file's dir
  } else {                                    # func - go to the its definition
    local type="$( type -w -- "$input" )"  # outputs smth like `ls: command`
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
  (( exit_code )) && return exit_code

  # ———————————————————————————————————————————————————————————————————————— #

  # I can't think of why else `cd` would fail, other than lack of perms
  ls -- "$target" &>/dev/null || { goto::error perms; return 3; }

  # if `cd` succeeds, print `cd $PATH_TO/target`
  if (( show_cd_cmd )) abbrpath -C cd -- "$target" >&2

  return 0
}
