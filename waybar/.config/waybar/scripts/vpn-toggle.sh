#!/usr/bin/env bash
VPN_NAME="SoftSolutions"
CONFIG_NAME="softsolutions"
VPN_CONFIG="$HOME/vpn/softsol.ovpn"

notify() {
  notify-send -a "OpenVPN3" "$1" "$2"
}

is_connected() {
  openvpn3 sessions-list 2>/dev/null | grep -q "Client connected"
}

get_session_path() {
  openvpn3 sessions-list 2>/dev/null | grep "Path:" | awk '{print $2}'
}

get_vpn_ip() {
  ip -4 addr show tun0 2>/dev/null | awk '/inet /{print $2}' | cut -d'/' -f1
}

case "$1" in
toggle)
  if is_connected; then
    # Disconnect
    SESSION_PATH=$(get_session_path)
    [ -n "$SESSION_PATH" ] && openvpn3 session-manage --path "$SESSION_PATH" --disconnect
    notify "VPN Disconnected" "$VPN_NAME disconnected"
  else
    # Connect
    if ! openvpn3 configs-list 2>/dev/null | grep -q "$CONFIG_NAME"; then
      openvpn3 config-import --config "$VPN_CONFIG" --name "$CONFIG_NAME" --persistent
    fi

    # Launch terminal for interactive credential/MFA entry
    xdg-terminal-exec bash -c "openvpn3 session-start --config $CONFIG_NAME; echo 'Press Enter to close...'; read" &
    notify "VPN Connecting" "Enter credentials in terminal"
  fi
  ;;

*)
  # Status for waybar
  if is_connected; then
    IP=$(get_vpn_ip)
    echo "{\"text\":\"󰌾 VPN\",\"class\":\"connected\",\"tooltip\":\"$VPN_NAME\n${IP:-Connected}\"}"
  else
    echo "{\"text\":\"󰌿 VPN\",\"class\":\"disconnected\",\"tooltip\":\"Click to connect\"}"
  fi
  ;;
esac
