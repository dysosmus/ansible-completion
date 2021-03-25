# DEPRECATED 
[As of Ansible 2.9, you can add shell completion of the Ansible command line utilities by installing an optional dependency called argcomplete. argcomplete supports bash, and has limited support for zsh and tcsh.](https://docs.ansible.com/ansible/devel/installation_guide/intro_installation.html#shell-completion)

# ansible-completion


Provide a bash completion on host name, module name and options for [ansible](https://github.com/ansible/ansible "ansible git repository").

## Installation

 1. Get the `ansible-completion.bash` file.

 2. Copy/move the `ansible-completion.bash` in your `bash_completion.d`
    folder (`/etc/bash_completion.d`, `/usr/local/etc/bash_completion.d`or `~/bash_completion.d`).

 3. **Or** copy/move it where you want and then load the `ansible-completion.bash` file in your `~/.bashrc` or `~/.profile` like that: 
 		source ~/ansible-completion.bash

 4. Reload your shell with something like `source ~/.bashrc` or `source ~/.profile`

### Note for OSX

1. Clone the repo, install bash an auto-completion2 with homebew: ```brew install bash bash-completion2```
2. Change your terminal bash to a homebrew one by setting the ```command``` option to ```/usr/local/bin/bash```
3. Add the following code to your ```~/.profile```:

    ```
    if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
      . $(brew --prefix)/share/bash-completion/bash_completion
    fi
    ```
2. Create a symbolik link for ```	ansible-completion.bash```:

    ```
    ln -vs ~/soft/ansible-completion/ansible-completion.bash /usr/local/share/bash-completion/completions/ansible
    ```

## Good to know

If the `--module-path` (`-M`) or `--inventory-file` (`-i`) is on the command line, the completion will use it.

For the completion on module name, the completion script build a cache of modules names.

You can set the cache timeout with the environement variable `ANSIBLE_COMPLETION_CACHE_TIMEOUT`, the default value is `120` seconds.

## Contributors

- [ogarcia](https://github.com/ogarcia)
- [pheanex](https://github.com/pheanex) (ansible-* completions) 
- [DenKoren](https://github.com/DenKoren)
- [hryamzik](https://github.com/hryamzik) 
- [mrqwer88](https://github.com/mrqwer88)
- [wolfgangkarall](https://github.com/wolfgangkarall)

