#!/usr/bin/env zsh

function goto() {
  setopt local_options warn_create_global

  # ———————————————————————————————————————————————————————————————————————— #

  local -rA opt_aliases=(
    [--chase-links]='-L'
    [--interactive]='-i'
    [--no-errors]='-q'   [--quiet]='-q'
    [--no-cd-cmd]='-Q'   [--QUIET]='-Q'
  )

  local -i 2 chase_links=0 interactive=0
  local -i 2 show_errors=1 show_cd_cmd=1

  local opt char_opt type

  for opt in "$@"; {
    # if `$opt` has an `--opt-name` alias, replace it. If not, re-insert `$opt`
    opt="${opt_aliases[$opt]:-$opt}"
    # this does the same thing as above, but for `+-opt-name`
    opt="${${opt_aliases[${opt/#+/-}]/#-/+}:-$opt}"

    if [[ "$opt" == [-+]-  ]] { shift; break; }  # break on `--` or `+-` (GNU)
    if [[ "$opt" != [-+]*  ]] { break; }  # break if the input isn't an option

    # if a long-form `--opt` / `+-opt` option still exists, it must be invalid
    if [[ "$opt" == [-+]-* ]] { goto::error opts "$opt"; return 1; }

    shift  # now we know that `$opt` is a valid option, remove it from `$*`
    type="$opt[1]"  # find out whether the option starts with `-` or `+`

    # remove the leading char, and split `$opt` into separate options,
    #  so smth like `goto +ab -b-d` will be parsed as `goto +a +b -c -- -d`
    for char_opt in "${(@s::)opt#[-+]}"; { #
      case "$char_opt" {
       ( L ) (( chase_links = ${#type#+} )) ;;
       ( i ) (( interactive = ${#type#+} )) ;; 
       ( q ) (( show_errors = ${#type#-} )) ;;
       ( Q ) (( show_cd_cmd = ${#type#-} )) ;;
       ( - ) break 2 ;;  # break on `--` or `+-`, per GNU standards
       ( * ) goto::error opts $char_opt; return 1 ;;
      }
    }
  }

  # ———————————————————————————————————————————————————————————————————————— #

  # concatenate the input with `$IFS`, so an unquoted input like
  #  `/path to/some dir` will be read as one argument: `"/path to/some dir"`
  local IFS=$' \t\n\0'
  # note: `-H` is used on vars containing paths, to hide them from `abbrpath`
  local -rH input="${*:-"$OLDPWD"}"

  # if no input was passed, or if it's all spaces, exit
  if [[ "$*" =~ '^ *$' ]] { goto::error input; return 1; }

  # ———————————————————————————————————————————————————————————————————————— #

  local -H target=  # will be set by one of the sub-functions

  if     [[ -d "$input" ]] { goto::directory  # dir  - just act like `cd`
  } elif [[ -e "$input" ]] { goto::file       # file - go to the file's dir
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

  # I can't think of why else `cd` would fail, other than lack of perms
  ls "$target" &>/dev/null || { goto::error perms; return 3; }

  # if `cd` succeeds, print `cd $PATH_TO/target`
  if (( show_cd_cmd )) abbrpath -C cd "$target" >&2

  return 0
}
