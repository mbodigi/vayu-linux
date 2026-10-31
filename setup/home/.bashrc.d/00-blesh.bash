# ble.sh (fish-style suggestions + syntax colors), built from github.com/akinomyoga/ble.sh into ~/.local.
# Loaded first without attaching; zz-blesh-attach.bash switches it on after everything else.
# Only in real terminal windows: not in scripts, pipes or Claude Code's command runner.
if [[ $- == *i* && -t 0 && -t 1 && -z ${CLAUDECODE-} && -f ~/.local/share/blesh/ble.sh ]]; then
    source ~/.local/share/blesh/ble.sh --noattach
fi
