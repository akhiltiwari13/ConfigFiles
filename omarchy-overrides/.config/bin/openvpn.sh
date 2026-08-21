#!/usr/bin/env bash

# =========================================================
# OpenVPN Waybar Script
#
# AUTHENTICATION DOCUMENTATION
#
# - Gunakan `pkexec` jika:
#   ✔ ingin popup autentikasi GUI
#   ✔ ingin fingerprint (PAM / fprintd)
#   ✔ digunakan di Wayland / Hyprland / Waybar
#   → Tidak perlu `visudo`
#
# - Gunakan `sudo` + `visudo` jika:
#   ✔ environment CLI / server
#   ✔ tidak butuh fingerprint
#   ✔ tidak dipanggil dari GUI
#
# Catatan penting:
# - Jangan menggabungkan `sudo` dan `pkexec`
# - `pkexec` selalu dipanggil dari user biasa
# =========================================================

TUN_IF="tun0"
VPN_NAME="TaufikIT"
VPN_CONFIG="$HOME/vpn/softsol.ovpn"
PASS_FILE="$HOME/vpn/credentials.txt"

notify() {
  notify-send -a "OpenVPN" "$1" "$2"
}

is_connected() {
  ip link show "$TUN_IF" >/dev/null 2>&1
}

case "$1" in
toggle)
  if is_connected; then
    # sudo pkill openvpn
    pkexec pkill openvpn

    notify "VPN Disconnected" "$VPN_NAME has been disconnected"
  else
    # sudo openvpn --config "$VPN_CONFIG" --askpass "$PASS_FILE" --daemon
    pkexec openvpn \
      --config "$VPN_CONFIG" \
      --askpass "$PASS_FILE" \
      --daemon

    sleep 2

    if is_connected; then
      IP=$(ip -4 addr show "$TUN_IF" | awk '/inet /{print $2}')
      notify "VPN Connected" "$VPN_NAME\nIP: $IP"
    else
      notify "VPN Error" "Failed to establish VPN connection"
    fi
  fi
  ;;
*)
  if is_connected; then
    IP=$(ip -4 addr show "$TUN_IF" | awk '/inet /{print $2}')
    echo "{\"text\":\"󰌾 VPN\",\"class\":\"connected\",\"tooltip\":\"$VPN_NAME\n$IP\"}"
  else
    echo "{\"text\":\"󰌿 VPN\",\"class\":\"disconnected\",\"tooltip\":\"OpenVPN disconnected\"}"
  fi
  ;;
esac
