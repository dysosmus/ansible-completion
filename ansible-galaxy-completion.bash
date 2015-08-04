#!/bin/env bash

_ansible-galaxy() {
    local current_word=${COMP_WORDS[COMP_CWORD]}
    local previous_word=${COMP_WORDS[COMP_CWORD - 1]}
    local options="init info install list remove"

    case $previous_word in
    init )
        options="-p --init-path --offline -s --server -f --force"
        ;;
    info )
        options="-p --roles-path -s --server"
        ;;
    install )
        options="-i --ignore-errors -n --no-deps
                 -r --role-file -p --roles-path -s --server -f --force"
        ;;
    list )
        options="-p --roles-path"
        ;;
    remove )
        options="-p --roles-path"
        ;;
    esac

    case $previous_word in
        init|info|install|list|remove)
            options="${options} -h --help"
            if [[ "$current_word" == -* ]]; then
                COMPREPLY=( $( compgen -W "$options" -- "$current_word" ) )
            fi
            ;;
        *)
            COMPREPLY=( $( compgen -W "$options" -- "$current_word" ) )
            ;;
    esac
}

complete -o default -F _ansible-galaxy ansible-galaxy
