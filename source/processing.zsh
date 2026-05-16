#!/usr/bin/env zsh

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
