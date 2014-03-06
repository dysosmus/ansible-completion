#!/bin/env bash

_ansible() {
    local current_word=${COMP_WORDS[COMP_CWORD]}

    if [[ "$current_word" == -* ]]; then
        _ansible_complete_options "$current_word"
    else
        _ansible_complete_host "$current_word"
    fi
}

complete -o default -F _ansible ansible

# Compute completion with the available hosts, 
# if a inventory file is specified in 
# the command line the completion will use it
_ansible_complete_host() {
    local current_word=$1
    local inventory_file=$(_ansible_get_inventory_file)
    local hosts=$(ansible ${inventory_file:+-i "$inventory_file"} all --list-hosts 2>&1)

    COMPREPLY=( $( compgen -W "$hosts" -- "$current_word" ) )
}

# Look inside COMP_WORDS to find a value for the inventory-file argument
# and echo the value (or echo an empty string)
_ansible_get_inventory_file() {
    local index=0

    for word in ${COMP_WORDS[@]}; do
        index=$(expr $index + 1)
        if [ "$word" != "${COMP_WORDS[COMP_CWORD]}" ]; then
            if [[ "$word" == "-i" ]] || [[ "$word" == "--inventory-file" ]]; then
                echo ${COMP_WORDS[$index]}
                return 0
            fi
        fi
    done

    echo ""
    return 1
}

# Compute completion for the generics options
_ansible_complete_options() {
    local current_word=$1
    local options="-h --help -v --verbose -f --forks -i --inventory-file 
    -k --ask-pass --private-key -K --ask-sudo-pass 
    --ask-su-pass --ask-vault-pass --vault-password-file 
    --list-hosts -M --module-path -l --limit -T --timeout 
    -o --one-line -t --tree -s --sudo -U --sudo-user -u 
    --user -S --su -R --su-user -c --connection -P 
    --poll -B --background -C --check -a --args -m 
    --module-name"

    COMPREPLY=( $( compgen -W "$options" -- "$current_word" ) )
}   