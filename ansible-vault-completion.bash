#!/bin/env bash

_ansible-vault() {
    local current_word=${COMP_WORDS[COMP_CWORD]}
    local options="--accept-host-key -K --ask-sudo-pass -C --checkout
                   -d --directory -e --extra-vars -f --force -h --help
                   -i --inventory-file --key-file -m --module-name -o
                   --only-if-changed --purge -s --sleep -t --tags -U
                   --url --vault-password-file -v --verbose"

    if [[ "$current_word" == -* ]]; then
        COMPREPLY=( $( compgen -W "$options" -- "$current_word" ) )
    fi
}

complete -o default -F _ansible-vault ansible-vault
