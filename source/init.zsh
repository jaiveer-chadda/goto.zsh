#!/usr/bin/env zsh

# ——————————————————————————————————————————————————————————————————————————— #

typeset -gi 10 GOTO_HIST_LINES=10000

typeset -g _GOTO_STACK_FILE="${0:h:h:a}/store/stack"
typeset -g  _GOTO_HIST_FILE="${0:h:h:a}/store/history"

chpwd_functions+=( 'goto::chpwd' )
chpwd_functions=( "${(@u)chpwd_functions}" )

# ——————————————————————————————————————————————————————————————————————————— #

source -- "$0:h/errors.zsh"
source -- "$0:h/processing.zsh"
source -- "$0:h/parse_opts.zsh"
source -- "$0:h/relative.zsh"

source -- "$0:h/goto.zsh"

# ——————————————————————————————————————————————————————————————————————————— #

goto::hist_cleanup

# ——————————————————————————————————————————————————————————————————————————— #

unalias g &>/dev/null || :
alias g=goto

# ——————————————————————————————————————————————————————————————————————————— #
