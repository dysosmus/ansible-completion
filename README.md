ansible-completion
==================
Provide a bash completion on host name, module name and options for [ansible](https://github.com/ansible/ansible "ansible git repository").

Installation
------------

 1. Get the `ansible-completion.bash` file.

 2. Copy/move the `ansible-completion.bash` in your `bash_completion.d`
    folder (`/etc/bash_completion.d`, `/usr/local/etc/bash_completion.d`or `~/bash_completion.d`).

 3. **Or** copy/move it where you want and then load the `ansible-completion.bash` file in your `~/.bashrc` or `~/.profile` like that:

 		source ~/ansible-completion.bash

 4. Reload your shell with something like `source ~/.bashrc` or `source ~/.profile`

Good to know
------------
If the `--module-path` (`-M`) or `--inventory-file` (`-i`) is on the command line, the completion will use it.

For the completion on module name, the completion script build a cache of modules names.<br />
You can set the cache timeout with the environement variable `ANSIBLE_COMPLETION_CACHE_TIMEOUT`, the default value is `120` secondes.

Contributors
-----------
- [mrqwer88](https://github.com/mrqwer88)
- [wolfgangkarall](https://github.com/wolfgangkarall)
