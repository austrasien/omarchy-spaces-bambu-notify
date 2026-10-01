# Spaces Bambu notify

User-level reporter that shows Bambu Lab print status on the [Omarchy Spaces](https://github.com/tornikegomareli/omarchy-spaces) bar (gold chip while printing, red `!` on pause/error, accent pulse when the job finishes).

Spaces is unchanged. This process watches the printer over MQTT and calls:

```
omarchy-shell tornikegomareli.spaces agent <session> <working|waiting|done|end> <pids>
```

`pids[0]` is this reporter (Spaces’ 60s liveness probe). A later PID is the `BambuStudio` window, so the badge sits on that icon. No Studio window → no badge; MQTT still runs in the background. Opening Studio sends `pushall` immediately. An `end` is delayed ~0.8 s so a splash→window remap does not clear the chip.

## Install (Omarchy)

```sh
git clone https://github.com/austrasien/omarchy-spaces-bambu-notify.git ~/.config/omarchy/spaces-bambu-notify
~/.config/omarchy/spaces-bambu-notify/install.sh
```

Then put a **account** token (not the 8-digit LAN code) in `~/.config/omarchy/bambu.env` (`chmod 600`) and restart:

```sh
systemctl --user restart spaces-bambu-notify
```

Cloud MQTT uses `us.mqtt.bambulab.com`. The LAN broker is single-client and fights Bambu Studio, so the reporter uses cloud when a token is present.

Token source: bambulab.com / MakerWorld → F12 → Application → Cookies → `token`. `CONNACK rc=5` means the token is dead; the reporter sends one desktop notification.

## Commands

```sh
systemctl --user status spaces-bambu-notify
journalctl --user -u spaces-bambu-notify -f
```

## Mapping

| MQTT `gcode_state` | Spaces |
|---|---|
| `RUNNING` / `PREPARE` / `SLICING` | gold chip (`working`) |
| `PAUSE` / `FAILED` / `print_error` | red `!` (`waiting`) |
| `FINISH` (job not yet acknowledged) | accent pulse (`done`) |
| idle, Studio closed, or `done` already seen | none (`end`) |

A `FINISH` that repeats while the part sits on the plate is acknowledged when Studio’s workspace is focused, so reopening Studio does not replay the pulse.

## Layout

| Path | Role |
|---|---|
| `spaces-bambu-notify` | reporter (Python 3, stdlib MQTT, no paho) |
| `spaces-bambu-notify.service` | systemd user unit |
| `bambu.env.example` | copied to `~/.config/omarchy/bambu.env` if missing — **never commit the real file** |

Requires Hyprland (`HYPRLAND_INSTANCE_SIGNATURE`), Omarchy Spaces, and Bambu Studio’s `BambuStudio.conf` for the printer serial.

## License

MIT. See [LICENSE](LICENSE).
