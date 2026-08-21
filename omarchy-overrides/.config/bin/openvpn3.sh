#!/usr/bin/env bash
# =========================================================
# OpenVPN3 Waybar Script
#
# AUTHENTICATION DOCUMENTATION
#
# openvpn3 uses D-Bus and doesn't require root/pkexec
# Credentials are handled via:
# - auth-user-pass in .ovpn config
# - credentials file referenced in config
# =========================================================

VPN_NAME="SoftSolutions"
CONFIG_NAME="softsolutions" # Name used in openvpn3 config-import
VPN_CONFIG="$HOME/vpn/softsol.ovpn"

notify() {
  notify-send -a "OpenVPN3" "$1" "$2"
}

is_connected() {
  openvpn3 sessions-list 2>/dev/null | grep -q "Status: Connection established"
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
    if [ -n "$SESSION_PATH" ]; then
      openvpn3 session-manage --path "$SESSION_PATH" --disconnect
      notify "VPN Disconnected" "$VPN_NAME has been disconnected"
    fi
  else
    # Connect
    # Check if config exists, if not import it
    if ! openvpn3 configs-list 2>/dev/null | grep -q "$CONFIG_NAME"; then
      openvpn3 config-import --config "$VPN_CONFIG" --name "$CONFIG_NAME" --persistent
    fi

    # Start session
    openvpn3 session-start --config "$CONFIG_NAME" 2>&1 |
      grep -q "Session path" &&
      notify "VPN Connecting" "$VPN_NAME is connecting..." ||
      notify "VPN Error" "Failed to start VPN session"

    # Wait for connection
    sleep 3
    if is_connected; then
      IP=$(get_vpn_ip)
      notify "VPN Connected" "$VPN_NAME\nIP: ${IP:-Acquiring...}"
    else
      notify "VPN Error" "Failed to establish connection"
    fi
  fi
  ;;

*)
  # Status output for waybar
  if is_connected; then
    IP=$(get_vpn_ip)
    echo "{\"text\":\"󰌾 VPN\",\"class\":\"connected\",\"tooltip\":\"$VPN_NAME\n${IP:-Connected}\"}"
  else
    echo "{\"text\":\"󰌿 VPN\",\"class\":\"disconnected\",\"tooltip\":\"OpenVPN disconnected\"}"
  fi
  ;;
esac
