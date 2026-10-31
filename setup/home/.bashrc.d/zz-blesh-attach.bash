# Switch ble.sh on last, after the rest of ~/.bashrc.d (see 00-blesh.bash)
[[ ${BLE_VERSION-} ]] && ble-attach
