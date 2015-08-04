#!/bin/env bash

_ansible-doc() {
    local current_word=${COMP_WORDS[COMP_CWORD]}
    local options="--version -h --help -M --module-path -l --list -s --snippet -v"

    if [[ "$current_word" == -* ]]; then
        COMPREPLY=( $( compgen -W "$options" -- "$current_word" ) )
    fi
}

complete -o default -F _ansible-doc ansible-doc
