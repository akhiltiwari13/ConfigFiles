#!/usr/bin/env bash
# install.sh — install this repo's /etc drop-ins for the system-hang mitigation.
#
# syshardening/ is NOT a stow package: stow targets $HOME (see stow/.stowrc) and
# cannot reach /etc. This script mirrors syshardening/etc/** into /etc/** instead.
# Same pattern as scripts/ — tracked in git, run directly.
#
# Every file installed is a discrete drop-in that OVERRIDES an Omarchy or distro
# default without editing it. Remove one file to undo one change.
#
# Usage:
#   sudo ./syshardening/install.sh              # install + reload services
#   sudo ./syshardening/install.sh --dry-run    # show what would change
#   sudo ./syshardening/install.sh --uninstall  # remove exactly what was installed
#
# Rationale for each file is in its own header comment, and in syshardening/PLAN.md.

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SRC_DIR="${SCRIPT_DIR}/etc"

usage() {
  sed -n '2,19p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
  exit 1
}

log() { echo "  [syshardening] $*"; }

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "error: must run as root (use sudo)" >&2
    exit 1
  fi
}

# Emit each tracked file as a relative path under etc/, e.g. "sysctl.d/99-foo.conf".
list_files() {
  ( cd "$SRC_DIR" && find . -type f -printf '%P\n' | sort )
}

do_install() {
  local mode="$1" rel src dst changed=0
  while IFS= read -r rel; do
    src="${SRC_DIR}/${rel}"
    dst="/etc/${rel}"
    if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
      log "unchanged  /etc/${rel}"
      continue
    fi
    changed=1
    if [ "$mode" = "dry" ]; then
      log "would install  /etc/${rel}"
    else
      install -D -m 0644 "$src" "$dst"
      log "installed  /etc/${rel}"
    fi
  done < <(list_files)
  return $(( changed == 0 ))
}

do_uninstall() {
  local mode="$1" rel dst
  while IFS= read -r rel; do
    dst="/etc/${rel}"
    [ -e "$dst" ] || continue
    if [ "$mode" = "dry" ]; then
      log "would remove  $dst"
    else
      rm -f "$dst"
      log "removed  $dst"
    fi
  done < <(list_files)
}

reload_services() {
  local mode="$1"
  if [ "$mode" = "dry" ]; then
    log "would reload: sysctl, udev rules, upower"
    return 0
  fi

  log "applying sysctl settings"
  sysctl --system >/dev/null

  log "reloading udev rules and re-triggering USB"
  udevadm control --reload-rules
  udevadm trigger --action=add --subsystem-match=usb

  if systemctl is-active --quiet upower; then
    log "restarting upower"
    systemctl restart upower
  fi
}

print_verify() {
  cat <<'EOF'

  Verify:
    sysctl kernel.sysrq kernel.hung_task_panic       # expect 1 and 1
    cat /sys/bus/usb/devices/3-6/power/control       # expect: on
    upower --dump | grep -iE 'percentage|warning'    # thresholds in effect

  After ~2 hours, confirm the Goodix reset loop has stopped (baseline ~118/hour):
    journalctl -k -b 0 --since "-2h" | grep -c 'usb 3-6:.*reset'   # expect 0

  NOTE: kernel.hung_task_panic=1 makes the machine auto-reboot on a stuck task
  instead of freezing. That is deliberate (see PLAN.md Phase 0c) — revert it once
  a stack trace has been captured from /sys/fs/pstore/.
EOF
}

main() {
  local mode="real" action="install"

  case "${1:-}" in
    --dry-run)   mode="dry" ;;
    --uninstall) action="uninstall" ;;
    "")          ;;
    *)           echo "unknown flag: $1" >&2; usage ;;
  esac

  [ "$mode" = "real" ] && require_root

  echo "syshardening: ${action}${mode:+ (${mode})}"
  echo "source: ${SRC_DIR}"
  echo ""

  if [ "$action" = "uninstall" ]; then
    require_root
    do_uninstall "$mode"
    [ "$mode" = "real" ] && reload_services "$mode"
    echo ""
    echo "✓ removed — reboot to clear kernel.* settings still live in memory"
    return 0
  fi

  do_install "$mode" || log "nothing to do — all files already current"
  reload_services "$mode"
  [ "$mode" = "real" ] && print_verify
  echo ""
  echo "✓ done"
}

main "$@"
