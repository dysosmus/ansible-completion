_ansible_vault() {
	local cur prev OPTS wanted
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	case $prev in
		# a filename (or similar) MUST directly follow these flags.
		# sugest nothing else
		--vault-id|--encrypt-vault-id|--vault-password-file|--encrypt-vault-id|--new-vault-password-file|--new-vault-id)
			# TODO not completely correct, since some of these allow
			# special forms starting with `@' (and more?)
			COMPREPLY=( $(compgen -A file -- $cur) )
			return
			;;
		--output)
			# `-' is stdout
			COMPREPLY=( - $(compgen -A file -- $cur) )
			return
			;;
		ansible-vault)
			COMPREPLY+=( $(compgen -W '--version' -- $cur) )
			;;
	esac

	COMPREPLY+=( $(compgen -W '-h --help -v -vvv -vvvv --verbose' -- $cur) )

	# only sugest verbs when none is given
	verbs='create decrypt edit view encrypt encrypt_string rekey'
	none=
	for verb in $verbs; do
		if [[ " ${COMP_WORDS[@]} " =~ " $verb" ]]; then
			contains=true
		fi
	done

	if [ "x$contains" = "x" ]; then
		COMPREPLY+=( $(compgen -W "$verbs" -- $cur) )
		return
	fi

	# flags applicable to all verbs
	wanted=( --vault-id
		# TODO these two are multually exclusive
		--ask-vault-password --vault-password-file
	)

	# verb specific flags
	case ${COMP_WORDS[1]} in
		create|edit)
			wanted+=( --encrypt-vault-id )
			;;
		decrypt)
			wanted+=( --output )
			;;
		encrypt)
			wanted+=( --output --encrypt-vault-id )
			;;
		encrypt_string)
			wanted+=( --output --encrypt-vault-id -p --prompt -n --name --stdin-name )
			;;
		rekey)
			wanted+=( --encrypt-vault-id
				# TODO these two are multually exclusive
				--new-vault-password-file --new-vault-id
			)
			;;
	esac

	# don't recommend the same flag twice
	actually_wanted=()
	for w in "${wanted[@]}"; do
		if [[ ! " ${COMP_WORDS[@]} " =~ " $w" ]]; then
			actually_wanted+=( $w )
		fi
	done

	COMPREPLY+=( $(compgen -W "${actually_wanted[*]}" -- "${cur}" ) )

	# everything except encrypt_string takes any number of files
	if [ "${COMP_WORDS[1]}" != 'encrypt_string' ]; then
		COMPREPLY+=( $(compgen -A file -- $cur) )
	fi

}
complete -F _ansible_vault ansible-vault
