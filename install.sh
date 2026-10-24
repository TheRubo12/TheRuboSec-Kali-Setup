#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
for cmd in python3 ip openvpn rsvg-convert; do
  command -v "$cmd" >/dev/null || { echo "Falta $cmd. Consulta README.md" >&2; exit 1; }
done
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/therubosec/icons" "$HOME/.config/therubosec" "$HOME/.config/htb-vpn"
chmod 700 "$HOME/.config/therubosec" "$HOME/.config/htb-vpn"
for script in connecthtb settarget target-status htb-status; do
  if [[ -e "$HOME/.local/bin/$script" ]]; then
    cp -p "$HOME/.local/bin/$script" "$HOME/.local/bin/$script.bak.$(date +%Y%m%d%H%M%S)"
  fi
  install -m 755 "$ROOT/bin/$script" "$HOME/.local/bin/$script"
done
rsvg-convert -w 20 -h 20 "$ROOT/assets/icons/target.svg" -o "$HOME/.local/share/therubosec/icons/target-red.png"
rsvg-convert -w 20 -h 20 "$ROOT/assets/icons/htb-cube.svg" -o "$HOME/.local/share/therubosec/icons/htb-lime.png"
echo 'Instalado. Añade ~/.local/bin a PATH y configura los dos Generic Monitor del panel XFCE (README).'
