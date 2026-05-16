#!/usr/bin/env zsh

typeset -ga chpwd_functions=( "${(@)chpwd_functions}" 'goto::chpwd' )
chpwd_functions=( "${(@u)chpwd_functions}" )

function goto::chpwd() {
  :
}

function goto::relative() {
  echo 'Not implemented' >&2
}
