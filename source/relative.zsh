#!/usr/bin/env zsh

# ——————————————————————————————————————————————————————————————————————————— #

function goto::line_count() {
  # get the `wc -l` of the file, then strip the leading spaces,
  #  then remove everything after the first space, leaving just the number
  # (the `-nE -` is all technically superfluous, but I prefer it just in case)
  echo -nE - "${${(*)$( wc -l "$1" )/# ##}%% *}"
}

# ——————————————————————————————————————————————————————————————————————————— #

function goto::chpwd() {
  # I honestly can't be arsed to deal with newlines in dir names
  # if [[ -w "$_GOTO_HIST_FILE" && "$PWD" != *$'\n'* ]] {
  # if [[ "$PWD" != *$'\n'* ]] {
  # }
  echo -E - "${PWD//$'\n'/␤}" 2>/dev/null >> "$_GOTO_HIST_FILE" || :
}

# ——————————————————————————————————————————————————————————————————————————— #

function goto::relative() {
  #r)NOT FINISHED
  if (( relative_dir >= 0 )) echo 'Not implemented' >&2 && return 1

  # remove the leading minus to get the absolute value of `$relative_dir`
  local -ri 10      dir_no=${relative_dir#-}
  local -ri 10  line_count=$( goto::line_count "$_GOTO_HIST_FILE" )
  local -ri 10 line_to_get=$(( line_count - dir_no ))

  # get the nᵗʰ line of the hist file
  target="$( command sed "${line_to_get}q;d" "$_GOTO_HIST_FILE" )"

  if ! [[ -d "$target" ]] {
    goto::error exist
    # todo: delete the file from the hist file
    return 1
  }

  echo $target

  return 1
}

# ——————————————————————————————————————————————————————————————————————————— #

function goto::hist_cleanup() {
  local -ri 10 line_count=$( goto::line_count "$_GOTO_HIST_FILE" )

  # we're not gonna do anything unless `$line_count > $GOTO_HIST_LINES`
  if (( line_count <= GOTO_HIST_LINES )) return 0

  # I had to split up the `tail` cmd and the redirection to `$_GOTO_HIST_FILE`
  #  cos if I don't, the `>` will truncate the file before its read
  local -r keep_lines="$( command tail -n $GOTO_HIST_LINES "$_GOTO_HIST_FILE" )"
  echo -E - "$keep_lines" > "$_GOTO_HIST_FILE"
}

# ——————————————————————————————————————————————————————————————————————————— #
