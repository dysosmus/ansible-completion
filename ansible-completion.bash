#!/bin/env bash

_ansible() {
    local current_word=${COMP_WORDS[COMP_CWORD]}
    
    if [[ "$current_word" == -* ]]; then
        _ansible_complete_options "$current_word"
    else
        _ansible_complete_host "$current_word"
    fi
}

_ansible_complete_host() {
    local host=$(ansible all --list-host 2> /dev/null)
    local current_word=$1

    COMPREPLY=( $( compgen -W "$options" -- "$current_word" ) )
}

_ansible_complete_options() {
    local options="-h --help -v --verbose -f --forks -i --inventory-file 
    -k --ask-pass --private-key -K --ask-sudo-pass 
    --ask-su-pass --ask-vault-pass --vault-password-file 
    --list-hosts -M --module-path -l --limit -T --timeout 
    -o --one-line -t --tree -s --sudo -U --sudo-user -u 
    --user -S --su -R --su-user -c --connection -P 
    --poll -B --background -C --check -a --args -m 
    --module-name"

    local current_word=$1

    COMPREPLY=( $( compgen -W "$options" -- "$current_word" ) )
}   

complete -o default -F _ansible ansible