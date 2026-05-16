#!/usr/bin/env zsh

function goto::parse_opts() {

  local -rA opt_aliases=(
    [--chase-links]='-L'
    [--interactive]='-i'
    [--no-errors]='-q'   [--quiet]='-q'
    [--no-cd-cmd]='-Q'   [--QUIET]='-Q'
  )

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
       ( * ) goto::error opts $type$char_opt; return 1 ;;
      }
    }
  }

  inputs=( "$@" )
}
