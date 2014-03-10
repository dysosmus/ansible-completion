#!/bin/env bash

if [[ -z "$ANSIBLE_COMPLETION_CACHE_TIMEOUT" ]]; then
    ANSIBLE_COMPLETION_CACHE_TIMEOUT=120 # sec
fi

_ansible() {
    local current_word=${COMP_WORDS[COMP_CWORD]}
    local previous_word=${COMP_WORDS[COMP_CWORD - 1]}

    if [[ "$previous_word" == "-m" ]] || [[ "$previous_word" == "--module-name" ]]; then 
        _ansible_complete_option_module_name "$current_word"
    elif [[ "$current_word" == -* ]]; then
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
_ansible_get_inventory_file() { # @todo refactor with _ansible_get_module_path
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

_ansible_get_module_path() { # @todo @see _ansible_get_inventory_file
    local index=0

    for word in ${COMP_WORDS[@]}; do
        index=$(expr $index + 1)
        if [ "$word" != "${COMP_WORDS[COMP_CWORD]}" ]; then
            if [[ "$word" == "-M" ]] || [[ "$word" == "--module-path" ]]; then
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

_ansible_get_module_list() {
    echo > /tmp/a

    local module_path=$(_ansible_get_module_path) 
    local hash_module_path=$(md5 -q -s "$module_path")
    # /tmp/<pid>.<hash of the module path if exsist>.module-name.ansible.completion
    local cache_file=/tmp/${$}.${module_path:+"$hash_module_path".}module-name.ansible.completion 

    if [ -f "$cache_file" ]; then
        local timestamp=$(expr $(_timestamp) - $(_timestamp_last_modified $cache_file))
        if [ "$timestamp" -gt "$ANSIBLE_COMPLETION_CACHE_TIMEOUT" ]  ; then
            echo $(ansible-doc ${module_path:+-M "module_path"} -l | awk '{print $1}') > $cache_file            
        fi
    else 
        # We need to cache the output because ansible-doc is so fucking slow 
        echo $(ansible-doc -l | awk '{print $1}') > $cache_file
    fi

    echo $(cat $cache_file)
}

_ansible_complete_option_module_name() {
    local current_word=$1
    local module_list=$(_ansible_get_module_list)

    COMPREPLY=( $( compgen -W "$module_list" -- "$current_word" ) )
}

_timestamp() {
    echo $(date +%s)
}

_timestamp_last_modified()  {
    echo $(stat -f "%Sm" -t "%s" $1)
}