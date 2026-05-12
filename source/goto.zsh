#!/usr/bin/env zsh

unalias g &>/dev/null || :
alias g=goto

# ——————————————————————————————————————————————————————————————————————————— #

goto() {
  # concatenate the input with `$IFS`, so an unquoted input like
  #  `/path to/some dir` will be read as one argument: `"/path to/some dir"`
  local IFS=$' \t\n\0'
  local -rH input="${*:-"$OLDPWD"}"
  local -r  error="\e[31m$0\e[m: couldn't find \e[94m\`$input\`\e[m"
  local -H  goto=

  if     [[ -d "$input" ]] { goto="$input:a"    # directory
  } elif [[ -e "$input" ]] { goto="$input:a:h"  # file

  } elif [[ "$( type -w "$input" 2>/dev/null )" == *'function' ]] {  # function
    local -H func_path="$( whence -v "$input" 2>/dev/null )"

    func_path="/${func_path#$input is*/}"
    goto="$func_path:h"

  } else { echo "$error" >&2; return 1; }

  { echo -n $'\e[94mcd\e[m '
    abbrpath "$goto"
  } >&2

  cd "$goto" &>/dev/null || { echo "$error" >&2; return 1; }
}
