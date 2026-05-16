#!/usr/bin/env zsh

source "$0:h/errors.zsh"
source "$0:h/processing.zsh"
source "$0:h/parse_opts.zsh"
source "$0:h/relative.zsh"

source "$0:h/goto.zsh"

unalias g &>/dev/null || :
alias g=goto
