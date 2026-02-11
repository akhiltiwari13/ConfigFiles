#!/usr/bin/env bash

# VPN Configurations: name|path|display_name|needs_auth
declare -A VPNS=(
  # ["softsolutions"]="$HOME/vpn/softsol.ovpn|SoftSolutions|true"
  ["axtior"]="$HOME/vpn/axtior.ovpn|Axtior|false"
)

notify() {
  notify-send -a "OpenVPN3" "$1" "$2"
}

is_connected() {
  openvpn3 sessions-list 2>/dev/null | grep -q "Client connected"
}

get_active_vpn() {
  openvpn3 sessions-list 2>/dev/null | grep "Config name:" | awk -F'/' '{print $NF}' | sed 's/.ovpn.*//'
}

get_session_path() {
  openvpn3 sessions-list 2>/dev/null | grep "Path:" | awk '{print $2}'
}

get_vpn_ip() {
  ip -4 addr show tun0 2>/dev/null | awk '/inet /{print $2}' | cut -d'/' -f1
}

connect_vpn() {
  local vpn_key=$1
  IFS='|' read -r config_path vpn_name needs_auth <<<"${VPNS[$vpn_key]}"

  # Import if not exists
  if ! openvpn3 configs-list 2>/dev/null | grep -q "$vpn_key"; then
    openvpn3 config-import --config "$config_path" --name "$vpn_key" --persistent
  fi

  if [ "$needs_auth" = "true" ]; then
    # Open terminal for password entry
    xdg-terminal-exec bash -c "openvpn3 session-start --config $vpn_key; echo 'Press Enter to close...'; read" &
    notify "VPN Connecting" "Connecting to $vpn_name (enter credentials)"
  else
    # No password needed - connect directly
    openvpn3 session-start --config "$vpn_key" &>/dev/null &
    notify "VPN Connecting" "Connecting to $vpn_name"
  fi
}

case "$1" in
toggle)
  if is_connected; then
    # Disconnect
    SESSION_PATH=$(get_session_path)
    [ -n "$SESSION_PATH" ] && openvpn3 session-manage --path "$SESSION_PATH" --disconnect
    notify "VPN Disconnected" "VPN disconnected"
  else
    # Show menu to select VPN (install wofi: sudo pacman -S wofi)
    selected=$(printf "%s\n" "${!VPNS[@]}" | wofi --dmenu -p "Select VPN:")

    if [ -n "$selected" ]; then
      connect_vpn "$selected"
    fi
  fi
  ;;

connect-softsolutions)
  connect_vpn "softsolutions"
  ;;

connect-axtior)
  connect_vpn "axtior"
  ;;

*)
  # Status for waybar
  if is_connected; then
    ACTIVE_VPN=$(get_active_vpn)
    IFS='|' read -r _ VPN_DISPLAY_NAME _ <<<"${VPNS[$ACTIVE_VPN]}"
    IP=$(get_vpn_ip)
    echo "{\"text\":\"󰌾 ${VPN_DISPLAY_NAME:-VPN}\",\"class\":\"connected\",\"tooltip\":\"${VPN_DISPLAY_NAME:-Connected}\n${IP:-Connected}\"}"
  else
    echo "{\"text\":\"󰌿 VPN\",\"class\":\"disconnected\",\"tooltip\":\"Click to select VPN\"}"
  fi
  ;;
esac
