#!/usr/bin/env bash
set -euo pipefail

DEVICE="${1:-}"
ADB=(adb)
if [[ -n "$DEVICE" ]]; then
  ADB+=( -s "$DEVICE" )
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/diagnostics"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT_FILE="$OUT_DIR/avas-$STAMP.txt"

mkdir -p "$OUT_DIR"

run() {
  local title="$1"
  shift
  {
    echo
    echo "===== $title ====="
    "$@"
  } >>"$OUT_FILE" 2>&1 || {
    echo "[command failed: $*]" >>"$OUT_FILE"
  }
}

has_device() {
  "${ADB[@]}" get-state >/dev/null 2>&1
}

{
  echo "BYD AVAS diagnostics"
  echo "Generated: $(date)"
  echo "Device arg: ${DEVICE:-<default>}"
  echo
  echo "===== adb devices ====="
  adb devices -l
} >"$OUT_FILE"

if ! has_device; then
  {
    echo
    echo "No online ADB device is available. Connect the car/head unit and run again:"
    echo "  bash scripts/diagnose-avas.sh"
    echo "or, with an explicit serial:"
    echo "  bash scripts/diagnose-avas.sh <serial>"
  } >>"$OUT_FILE"
  echo "$OUT_FILE"
  exit 2
fi

PATTERN='avas|pedestrian|acoustic|vehicle alert|alerting|vess|evsound|ev_sound|warning.?sound|low.?speed.?sound|sound.?warn'

run "device identity" "${ADB[@]}" shell sh -c 'getprop ro.product.manufacturer; getprop ro.product.model; getprop ro.build.display.id; getprop ro.build.version.release'
run "AVAS-like properties" "${ADB[@]}" shell sh -c "getprop | grep -Ei '$PATTERN|byd.*sound|sound.*byd' || true"
run "AVAS-like settings: global" "${ADB[@]}" shell sh -c "settings list global | grep -Ei '$PATTERN' || true"
run "AVAS-like settings: system" "${ADB[@]}" shell sh -c "settings list system | grep -Ei '$PATTERN' || true"
run "AVAS-like settings: secure" "${ADB[@]}" shell sh -c "settings list secure | grep -Ei '$PATTERN' || true"
run "AVAS-like packages" "${ADB[@]}" shell sh -c "pm list packages -f | grep -Ei '$PATTERN|byd.*sound|sound.*byd|audio|vehicle' || true"
run "AVAS-like services" "${ADB[@]}" shell sh -c "service list | grep -Ei '$PATTERN|audio|vehicle|byd' || true"
run "Audio service summary" "${ADB[@]}" shell dumpsys audio
run "Audio flinger AVAS-like lines" "${ADB[@]}" shell sh -c "dumpsys media.audio_flinger | grep -Ei '$PATTERN|byd|external|speaker' || true"
run "Recent logs" "${ADB[@]}" logcat -d -t 4000 -v time '*:V'
run "Recent filtered AVAS-like logs" bash -c '
  adb_args=()
  if [[ -n "$0" ]]; then
    adb_args=(-s "$0")
  fi
  adb "${adb_args[@]}" logcat -d -t 8000 -v time "*:V" |
    grep -Ei "$1|byd.*sound|sound.*byd|audio|AudioFlinger|AudioTrack|CarAudio" || true
' "$DEVICE" "$PATTERN"

echo "$OUT_FILE"
