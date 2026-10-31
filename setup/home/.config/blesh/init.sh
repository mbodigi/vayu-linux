# ble.sh settings (loaded by ble.sh itself)

# Tab accepts the gray suggestion when one is showing (like fish); with no suggestion it completes as usual.
# Right arrow / End still accept it too.
ble-bind -m auto_complete -f TAB auto_complete/insert

# Colors: terminal palette numbers, so they follow the matugen Ghostty theme
# (4 primary, 5 secondary, 6 tertiary, 7 text, 8 dim; 1 red stays fixed for errors)
ble-face -s command_builtin   fg=4
ble-face -s command_alias     fg=4
ble-face -s command_function  fg=4
ble-face -s command_file      fg=4
ble-face -s command_keyword   fg=5,bold
ble-face -s command_directory fg=5,underline
ble-face -s filename_directory fg=5,underline
ble-face -s syntax_quoted     fg=6
ble-face -s syntax_quotation  fg=6,bold
ble-face -s syntax_varname    fg=6
ble-face -s syntax_param_expansion fg=6
ble-face -s syntax_comment    fg=8
ble-face -s syntax_error      fg=1,bold
ble-face -s auto_complete     fg=8
