# Interactive bash: history, shell options and a few shortcuts (tab completion + Up/Down search: ~/.inputrc).
[[ $- == *i* ]] || return

# --- history: big, shared between windows, no duplicates
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T  '
shopt -s histappend cmdhist
# save each command right away and pick up ones from other windows
PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# --- shell options
shopt -s autocd cdspell dirspell checkwinsize globstar

# --- shortcuts
alias ll='ls -lh --group-directories-first'
alias la='ls -lhA --group-directories-first'
alias ..='cd ..'
alias ...='cd ../..'


# --- prompt colors: palette 4 (primary) and 5 (secondary) from the matugen Ghostty theme,
#     instead of Fedora's fixed green (bash-color-prompt package)
if declare -F prompt_color >/dev/null; then
    prompt_color '1;38;5;4'       # user@host
    prompt_dir_color '38;5;5'     # ~/folder
fi

# --- zoxide: "z iso" jumps to the most used folder matching "iso" (learns as you cd)
command -v zoxide >/dev/null && eval "$(zoxide init bash)"
