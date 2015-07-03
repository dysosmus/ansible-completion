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
    local first_words=${current_word%:*}
    local last_word=${current_word##*:}
    local inventory_file=$(_ansible_get_inventory_file)
    local grep_opts="-o"
    # if $inventory_file is empty and a ansible.cfg file exisit
    # search in the ansible.cfg for a hostfile entry
    if [ -z "$inventory_file" ]; then
        [ -f /etc/ansible/ansible.cfg ] && inventory_file=$(awk \
            '/^inventory/{ print $3 }' /etc/ansible/ansible.cfg)
        [ -f ansible.cfg ] && inventory_file=$(awk '/^(hostname|inventory)/{ print $3 }' ansible.cfg)
    fi
    # if inventory_file points to a directory, search recursively
    [ -d "$inventory_file" ] && grep_opts="$grep_opts -hR"
    local hosts=$(ansible ${inventory_file:+-i "$inventory_file"} all --list-hosts 2>&1 \
        && [ -e "$inventory_file" ] \
        && [ ! -x "$inventory_file" ] \
        && grep $grep_opts '\[.*\]' "$inventory_file" | tr -d [] | cut -d: -f1)

    # list the hostnames with ansible command line and complete the list
    # by searching the group labels in the inventory file (if we have it)
    hosts="$hosts
    $(echo "$hosts" | sed -e 's/\([^[:space:]]\)/\&\1/p' -e 's/&/!/p' )"
    # add the !, & notation to the hostname


    if [ "$first_words" != "$last_word" ]; then
        COMPREPLY=( $( compgen -P "$first_words:" -W "$hosts" -- "$last_word" ) )
    else
        COMPREPLY=( $( compgen -W "$hosts" -- "$last_word" ) )
    fi
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
    local module_path=$(_ansible_get_module_path)
    local hash_module_path=$(_md5 "$module_path")
    # /tmp/<pid>.<hash of the module path if exsist>.module-name.ansible.completion
    local cache_file=/tmp/${$}.${module_path:+"$hash_module_path".}module-name.ansible.completion

    if [ -f "$cache_file" ]; then
        local timestamp=$(expr $(_timestamp) - $(_timestamp_last_modified $cache_file))
        if [ "$timestamp" -gt "$ANSIBLE_COMPLETION_CACHE_TIMEOUT" ]; then
            rm -f $cache_file > /dev/null 2>&1
            _generate_module_cache $cache_file $module_path
        fi
    else
        # We need to cache the output because ansible-doc is so fucking slow
        _generate_module_cache $cache_file $module_path
    fi

    echo $(cat $cache_file)
}

_generate_module_cache() {
    local cache_file=$1
    local module_path=$2

    ansible-doc ${module_path:+-M "$module_path"} -l | awk '{print $1}' > $cache_file
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
    local timestamp=''

    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # linux
        timestamp=$(stat -c "%Z" $1)
    else
        # freebsd/darwin
        timestamp=$(stat -f "%Sm" -t "%s" $1)
    fi

    echo $timestamp
}

_md5() {
    local to_hash=$1
    local md5_hash=''

    if hash md5 2>/dev/null; then
        # freebsd/darwin
        md5_hash=$(md5 -q -s "$to_hash")
    else
        # linux
        md5_hash=$(echo "$to_hash" | md5sum |awk {'print $1'})
    fi

    echo $md5_hash
}
