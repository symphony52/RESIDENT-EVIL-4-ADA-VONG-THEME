# Ada Wong Desktop Config

KDE Plasma / SDDM / Konsole customization for an Ada Wong and Resident Evil styled EndeavourOS setup.

This repository is meant as a portable dotfiles snapshot, not a blind system image. It includes the selected theme assets so the Ada Wong setup can be restored on another KDE install.

## Stack

- EndeavourOS / Arch Linux
- KDE Plasma 6 on Wayland
- SDDM with `Harmless-Game` theme
- Konsole profile: `Ada Wong`
- Plasma desktop theme: `Red-pastel`
- KDE color scheme: `Pastelred2`
- Icon theme: `Nature - Red - KDE`
- Cursor theme: `Doom`
- Aurorae window decorations: `Otto`, `ChromeOS-dark`
- Ada Wong wallpapers
- fish shell prompt with Umbrella/Resident Evil terminal status
- Bash fallback prompt and aliases

## Contents

- `configs/home/` - user dotfiles and KDE/Konsole/fish/bash configs
- `configs/etc/` - SDDM and keyboard system configs
- `themes/sddm/Harmless-Game/` - copied SDDM theme
- `themes/cursors/Doom/` - cursor theme
- `themes/icons/Nature - Red - KDE/` - icon theme
- `themes/plasma/desktoptheme/Red-pastel/` - Plasma shell theme
- `themes/aurorae/` - window decoration themes
- `wallpapers/Ada-Wong/` - bundled wallpapers used by the KDE config
- `packages/` - explicit, native, and AUR package lists
- `docs/system-inventory.md` - current system/theme inventory
- `scripts/install.sh` - cautious installer for home configs and user themes, with optional SDDM install

## Terminal Commands

After install:

```bash
re
threat
```

`re` prints the Umbrella control node banner. `threat` runs a short protocol scan panel.

Disable animation when needed:

```bash
RE_STATUS_ANIMATE=0 re-terminal-status
```

## Install

Check what the installer would change:

```bash
./scripts/install.sh --dry-run
```

Home configs only:

```bash
./scripts/install.sh
```

This installs the home dotfiles plus Konsole assets, color schemes, wallpapers, cursor theme, icon theme, Plasma theme, and Aurorae window decorations.

Include SDDM files and theme:

```bash
sudo ./scripts/install.sh --sddm
```

The installer creates timestamped backups before replacing files.

## Packages

Install native packages:

```bash
xargs -a packages/pkglist-native.txt sudo pacman -S --needed
```

Install AUR packages with `yay`:

```bash
xargs -a packages/pkglist-aur.txt yay -S --needed
```


