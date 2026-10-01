#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
bin_dir="${HOME}/.config/omarchy/bin"
unit_dir="${HOME}/.config/systemd/user"
env_file="${HOME}/.config/omarchy/bambu.env"

command -v python3 >/dev/null 2>&1 || {
  echo "python3 is required" >&2
  exit 1
}
command -v systemctl >/dev/null 2>&1 || {
  echo "systemctl is required" >&2
  exit 1
}

mkdir -p "$bin_dir" "$unit_dir"
ln -sfn "$root/spaces-bambu-notify" "$bin_dir/spaces-bambu-notify"
install -m 644 "$root/spaces-bambu-notify.service" "$unit_dir/spaces-bambu-notify.service"

if [[ ! -f $env_file ]]; then
  install -m 600 "$root/bambu.env.example" "$env_file"
  echo "Wrote $env_file (mode 600). Fill BAMBU_MQTT_PASSWORD, then:"
  echo "  systemctl --user restart spaces-bambu-notify"
fi

systemctl --user daemon-reload
systemctl --user enable --now spaces-bambu-notify
echo "spaces-bambu-notify enabled. Journal: journalctl --user -u spaces-bambu-notify -f"
