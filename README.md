# dotfiles

My Fedora KDE Plasma 6 setup: one light/dark theme across the whole desktop, Konsole, panel, shortcuts and shell.
Browse the configs one by one at [yakupemreyerli.com/dotfiles](https://yakupemreyerli.com/dotfiles/).

Kişisel Fedora KDE ayarlarım. Configleri tek tek görmek ve indirmek için:
[yakupemreyerli.com/tr/dotfiles](https://yakupemreyerli.com/tr/dotfiles/).

## What's inside

| Folder | What it is |
| --- | --- |
| `tema/` | `tema`, a small Python service that keeps Plasma, Konsole, Claude Code and the wallpaper on the same palette and follows the system light/dark switch. Palettes: GitHub Light and Tokyo Night (`secim.json`). |
| `kde/` | Color schemes (Yakup Açık / Yakup Koyu), global themes, panel layout, KWin, shortcuts, keyboard and mouse. |
| `konsole/` | Konsole profiles and color schemes, JetBrains Mono Nerd Font. |
| `shell/` | Bash: short `cd` to any project folder (case, Turkish letters and dots ignored), completion settings. |
| `git/` | Git defaults. |
| `boot/` | Plymouth theme for the boot and disk password screen. |

## My KDE projects

- [yakupemre-sddm](https://github.com/YakupEmreYerli/yakupemre-sddm): login screen theme
- [tray-grid](https://github.com/YakupEmreYerli/tray-grid): Windows-style hidden tray icon grid
- [ente-auth-plasmoid](https://github.com/YakupEmreYerli/ente-auth-plasmoid): Ente Auth 2FA codes in the panel
- [tuya-light](https://github.com/YakupEmreYerli/tuya-light): Tuya Wi-Fi bulbs from the panel

## Install

```bash
git clone https://github.com/YakupEmreYerli/dotfiles && cd dotfiles
./install            # everything, existing files are kept as .bak
./install konsole    # or just one folder
```

Log out and back in afterwards. The boot theme needs root, copy it to `/usr/share/plymouth/themes/` by hand.

## How it stays up to date

`manifest.tsv` lists every file and where it lives. `./sync` copies them from my machine, strips private lines and
runs a secret scan; a daily timer commits the changes.

## License

MIT
