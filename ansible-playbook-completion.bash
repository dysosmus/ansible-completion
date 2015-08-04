#!/bin/env bash

_ansible-playbook() {
    local current_word=${COMP_WORDS[COMP_CWORD]}
    local options="--ask-become-pass -k --ask-pass --ask-su-pass
                   -K --ask-sudo-pass --ask-vault-pass -b --become
                   --become-method --become-user -C --check -c
                   --connection -D --diff -e --extra-vars --flush-cache
                   --force-handlers -f --forks -h --help -i
                   --inventory-file -l --limit --list-hosts
                   --list-tags --list-tasks -M --module-path
                   --private-key --skip-tags --start-at-task
                   --step -S --su -R --su-user -s --sudo -U --sudo-user
                   --syntax-check -t --tags -T --timeout -u --user
                   --vault-password-file -v --verbose --version"

    if [[ "$current_word" == -* ]]; then
        COMPREPLY=( $( compgen -W "$options" -- "$current_word" ) )
    fi
}

complete -o default -F _ansible-playbook ansible-playbook
