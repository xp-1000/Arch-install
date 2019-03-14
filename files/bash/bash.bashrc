
### Tweaks bashrc

PS1="$(if [[ ${EUID} == 0 ]]; then echo '\[\033[01;31m\]\h'; else echo '\[\033[01;32m\]\u@\h'; fi)\[\033[01;34m\] \w \$([[ \$? != 0 ]] && echo \"\[\033[01;31m\]:(\[\033[01;34m\] \")\\$\[\033[00m\] "

## New options
# Enable options
shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s checkwinsize
shopt -s sourcepath
shopt -s no_empty_cmd_completion
shopt -s cmdhist
shopt -s histappend histreedit histverify
shopt -s extglob       # Necessary for programmable completion.
complete -cf sudo

# Disable options
shopt -u mailwarn
unset MAILCHECK        # Don't want my shell to warn me of incoming mail.

## Modified commands ## {{{
alias vi='vim'
alias diff='colordiff'              # requires colordiff package
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias less='less -R'
alias more='less'
alias df='df -h'
alias du='du -c -h'
alias mkdir='mkdir -p -v'
alias nano='nano -w'
alias wget='wget -c'
# }}}

## New commands ## {{{
alias da='date "+%y%m%d"'
alias dat='date "+%d/%m/%Y [%T]"'
alias du1='du --max-depth=1'
alias dusort='du -h * | sort -h'
alias hist='history | grep'         # requires an argument
alias ports='ss -plutan'
alias pss='ps -Af | grep'           # requires an argument
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
alias cpuinfo='lscpu'
alias copy='xclip -sel clip'
alias copp='xclip -sel clip -o'
alias pcinfo="sudo dmidecode | grep --color=never -A5 '^System Information' && grep 'model name' /proc/cpuinfo | head -n 1 | sed 's/model name[[:space:]]*:[[:space:]]*/CPU Model\n\t/' && grep MemTotal /proc/meminfo | sed 's/MemTotal:[[:space:]]*/Memory\n\t/'"
# }}}

# Privileged access
if [ $UID -ne 0 ]; then
    alias sudo='sudo '
    alias scat='sudo cat'
    alias svim='sudoedit'
    alias root='sudo -i'
    #alias reboot='sudo systemctl reboot'
    #alias poweroff='sudo systemctl poweroff'
    #alias netctl='sudo netctl'
fi

## ls ## {{{
alias ls='ls -hF --color=auto'
alias lr='ls -R'                    # recursive ls
alias ll='ls -l'
alias la='ll -a'
alias lx='ll -BX'                   # sort by extension
alias lz='ll -rS'                   # sort by size
alias lt='ll -rt'                   # sort by date
alias l.='ls -d .*'                 # show hidden files
# }}}

## Safety features ## {{{
alias mv='mv -i'
alias rm='rm -I'                    # 'rm -i' prompts for every file
# safer alternative w/ timeout, not stored in history
alias rm=' timeout 3 rm -Iv --one-file-system'
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias cls=' echo -ne "\033c"'       # clear screen for real (it does not work in Terminology)
# }}}

## Make Bash error tollerant ## {{{
alias cd..='cd ..'
# }}}

## Pacman aliases ## {{{
#if necessary, replace 'pacman' with your favorite AUR helper and adapt the commands accordingly
alias pac="sudo pacman -S"		                # default action	    - install one or more packages
alias pacu="sudo pacman -Syu"		            # '[u]pdate'		    - upgrade all packages to their newest version
alias pacr="sudo pacman -Rs"		            # '[r]emove'		    - uninstall one or more packages
alias pacs="pacman -Ss"		                    # '[s]earch'		    - search for a package using one or more keywords
alias pacsf="pacman -Fys"	                    # '[s]earch'		    - search for a package which contains a specific file
alias paci="pacman -Si"		                    # '[i]nfo'		        - show information about a package
alias paclo="pacman -Qdt"		                # '[l]ist [o]rphans'    - list all packages which are orphaned
alias pacro="pacman -Rns $(pacman -Qtdq)"       # '[r]emove [o]rphans'  - remove all packages which are orphaned
alias pacc="pacman -Sc" 		                # '[c]lean cache'       - delete all not currently installed package files
alias paclf="pacman -Ql"		                # '[l]ist [f]iles'      - list all files installed by a given package
alias pacexpl="pacman -D --asexp"	            # 'mark as [expl]icit'	- mark one or more packages as explicitly installed 
alias pacimpl="pacman -D --asdep"	            # 'mark as [impl]icit'	- mark one or more packages as non explicitly installed
alias pacrk="sudo pacman-key --refresh-keys"    # '[r]efresh [k]eys     - refresh pacman keys (error: key XXX could not be looked up remotely)
alias pacrank="curl -s 'https://www.archlinux.org/mirrorlist/?country=FR&country=DE&country=IT&country=GB&protocol=https&use_mirror_status=on' | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 6 - | sudo tee /etc/pacman.d/mirrorlist"
# }}}

## Functions
man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}

bigfiles() {
    if [ -z ${1} ]; then 
        size="50M"
    else
        size="${1}"
    fi
    find . -xdev -type f -size +${size} -exec ls -lh {} \; | awk '{ print $9 " : " $5 }'
}

# Powerline-go
function _update_ps1() {
    #PS1="$(powerline-go -modules venv,user,host,ssh,cwd,perms,git,hg,jobs,exit,root,kube -shorten-gke-names -error $?)"
    PS1="$(powerline-go -modules venv,user,ssh,cwd,perms,git,hg,jobs,exit,root,vgo,docker -theme ${HOME}/.config/powerline/theme.json -error $?)"
   # PS1="$(powerline-go -modules venv,user,host,ssh,cwd,perms,git,hg,jobs,exit,root,vgo,docker -error $?)"
}

if [ "$TERM" != "linux" ] && [ -f "$GOPATH/bin/powerline-go" ]; then
    export TERM='xterm-256color'
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

# fuck
#eval $(thefuck --alias --enable-experimental-instant-mode)
eval $(thefuck --alias)
