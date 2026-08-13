#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
stamp="$(date +%Y%m%d-%H%M%S)"
install_sddm=0
dry_run=0
target_user=${SUDO_USER:-${USER:-}}
target_home=${HOME}
target_group=

if [[ -n "$target_user" && "$target_user" != root ]]; then
    user_home=$(getent passwd "$target_user" | cut -d: -f6 || true)
    if [[ -n "$user_home" ]]; then
        target_home=$user_home
    fi
fi

for arg in "$@"; do
    case "$arg" in
        --sddm)
            install_sddm=1
            ;;
        --dry-run)
            dry_run=1
            ;;
        -h|--help)
            printf 'Usage: %s [--sddm] [--dry-run]\n' "$0"
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n' "$arg" >&2
            exit 2
            ;;
    esac
done

if [[ -n "$target_user" && "$target_user" != root ]]; then
    target_group=$(id -gn "$target_user" 2>/dev/null || true)
fi

home_files=(
    ".bashrc"
    ".dircolors-resident-evil"
    ".config/fish/config.fish"
    ".local/bin/re-terminal-status"
    ".local/share/konsole/Ada Wong.profile"
    ".local/share/konsole/Ada Wong.colorscheme"
    ".local/share/konsole/assets/resident-evil-terminal-bg.jpg"
    ".config/kdeglobals"
    ".config/kwinrc"
    ".config/kwinrulesrc"
    ".config/plasmarc"
    ".config/plasmashellrc"
    ".config/plasma-org.kde.plasma.desktop-appletsrc"
    ".config/ksplashrc"
    ".config/gtk-3-settings.ini"
    ".config/gtk-4-settings.ini"
    ".config/fontconfig-fonts.conf"
    ".local/share/color-schemes/Pastelred2.colors"
    ".local/share/color-schemes/ResidentEvilConsole.colors"
)

home_dirs=(
    "wallpapers/Ada-Wong:$target_home/.local/share/wallpapers/Ada-Wong"
    "themes/cursors/Doom:$target_home/.icons/Doom"
    "themes/icons/Nature - Red - KDE:$target_home/.local/share/icons/Nature - Red - KDE"
    "themes/plasma/desktoptheme/Red-pastel:$target_home/.local/share/plasma/desktoptheme/Red-pastel"
)

required_paths=()
for file in "${home_files[@]}"; do
    required_paths+=("$repo_dir/configs/home/$file")
done
for entry in "${home_dirs[@]}"; do
    required_paths+=("$repo_dir/${entry%%:*}")
done
required_paths+=("$repo_dir/themes/aurorae")

if ((install_sddm)); then
    required_paths+=(
        "$repo_dir/configs/etc/sddm.conf"
        "$repo_dir/configs/etc/sddm.conf.d/10-endeavouros.conf"
        "$repo_dir/configs/etc/sddm.conf.d/20-theme.conf"
        "$repo_dir/configs/etc/X11/xorg.conf.d/00-keyboard.conf"
        "$repo_dir/themes/sddm/Harmless-Game"
    )
fi

missing=0
for path in "${required_paths[@]}"; do
    if [[ ! -e "$path" ]]; then
        printf 'Missing required repository path: %s\n' "$path" >&2
        missing=1
    fi
done
if ((missing)); then
    exit 1
fi

run() {
    if ((dry_run)); then
        printf 'DRY-RUN:'
        printf ' %q' "$@"
        printf '\n'
        return 0
    fi
    "$@"
}

backup() {
    local path=$1
    if [[ -e "$path" || -L "$path" ]]; then
        run mkdir -p "$(dirname "$path")"
        run cp -a "$path" "$path.bak-$stamp"
    fi
}

copy_file() {
    local src=$1
    local dst=$2
    backup "$dst"
    run mkdir -p "$(dirname "$dst")"
    run install -m 0644 "$src" "$dst"
}

copy_exec() {
    local src=$1
    local dst=$2
    backup "$dst"
    run mkdir -p "$(dirname "$dst")"
    run install -m 0755 "$src" "$dst"
}

copy_dir() {
    local src=$1
    local dst=$2
    backup "$dst"
    run mkdir -p "$dst"
    run cp -a "$src/." "$dst/"
}

rewrite_home_paths() {
    local file=$1
    local escaped_home=${target_home//\\/\\\\}
    escaped_home=${escaped_home//&/\\&}

    [[ -f "$file" ]] || return 0
    grep -Iq . "$file" || return 0
    run sed -i "s|/home/symphony|$escaped_home|g" "$file"
}

copy_file "$repo_dir/configs/home/.bashrc" "$target_home/.bashrc"
copy_file "$repo_dir/configs/home/.dircolors-resident-evil" "$target_home/.dircolors-resident-evil"
copy_file "$repo_dir/configs/home/.config/fish/config.fish" "$target_home/.config/fish/config.fish"
copy_exec "$repo_dir/configs/home/.local/bin/re-terminal-status" "$target_home/.local/bin/re-terminal-status"

copy_file "$repo_dir/configs/home/.local/share/konsole/Ada Wong.profile" "$target_home/.local/share/konsole/Ada Wong.profile"
copy_file "$repo_dir/configs/home/.local/share/konsole/Ada Wong.colorscheme" "$target_home/.local/share/konsole/Ada Wong.colorscheme"
copy_file "$repo_dir/configs/home/.local/share/konsole/assets/resident-evil-terminal-bg.jpg" "$target_home/.local/share/konsole/assets/resident-evil-terminal-bg.jpg"

for file in kdeglobals kwinrc kwinrulesrc plasmarc plasmashellrc plasma-org.kde.plasma.desktop-appletsrc ksplashrc; do
    copy_file "$repo_dir/configs/home/.config/$file" "$target_home/.config/$file"
done

copy_file "$repo_dir/configs/home/.config/gtk-3-settings.ini" "$target_home/.config/gtk-3.0/settings.ini"
copy_file "$repo_dir/configs/home/.config/gtk-4-settings.ini" "$target_home/.config/gtk-4.0/settings.ini"
copy_file "$repo_dir/configs/home/.config/fontconfig-fonts.conf" "$target_home/.config/fontconfig/fonts.conf"
copy_file "$repo_dir/configs/home/.local/share/color-schemes/Pastelred2.colors" "$target_home/.local/share/color-schemes/Pastelred2.colors"
copy_file "$repo_dir/configs/home/.local/share/color-schemes/ResidentEvilConsole.colors" "$target_home/.local/share/color-schemes/ResidentEvilConsole.colors"

for entry in "${home_dirs[@]}"; do
    copy_dir "$repo_dir/${entry%%:*}" "${entry#*:}"
done

for aurorae_theme in "$repo_dir"/themes/aurorae/*; do
    [[ -d "$aurorae_theme" ]] || continue
    copy_dir "$aurorae_theme" "$target_home/.local/share/aurorae/themes/$(basename "$aurorae_theme")"
done

for file in "${home_files[@]}"; do
    case "$file" in
        .config/gtk-3-settings.ini)
            rewrite_home_paths "$target_home/.config/gtk-3.0/settings.ini"
            ;;
        .config/gtk-4-settings.ini)
            rewrite_home_paths "$target_home/.config/gtk-4.0/settings.ini"
            ;;
        .config/fontconfig-fonts.conf)
            rewrite_home_paths "$target_home/.config/fontconfig/fonts.conf"
            ;;
        *)
            rewrite_home_paths "$target_home/$file"
            ;;
    esac
done

if ((EUID == 0)) && [[ -n "$target_user" && "$target_user" != root && -n "$target_group" ]]; then
    run chown -R "$target_user:$target_group" \
        "$target_home/.bashrc" \
        "$target_home/.dircolors-resident-evil" \
        "$target_home/.icons/Doom" \
        "$target_home/.config/fish" \
        "$target_home/.config/kdeglobals" \
        "$target_home/.config/kwinrc" \
        "$target_home/.config/kwinrulesrc" \
        "$target_home/.config/plasmarc" \
        "$target_home/.config/plasmashellrc" \
        "$target_home/.config/plasma-org.kde.plasma.desktop-appletsrc" \
        "$target_home/.config/ksplashrc" \
        "$target_home/.config/gtk-3.0" \
        "$target_home/.config/gtk-4.0" \
        "$target_home/.config/fontconfig" \
        "$target_home/.local/bin/re-terminal-status" \
        "$target_home/.local/share/konsole" \
        "$target_home/.local/share/color-schemes" \
        "$target_home/.local/share/icons/Nature - Red - KDE" \
        "$target_home/.local/share/plasma/desktoptheme/Red-pastel" \
        "$target_home/.local/share/aurorae/themes" \
        "$target_home/.local/share/wallpapers/Ada-Wong"
fi

if ((install_sddm)); then
    if ((EUID != 0)); then
        printf 'Run with sudo for --sddm.\n' >&2
        exit 1
    fi

    copy_file "$repo_dir/configs/etc/sddm.conf" /etc/sddm.conf
    copy_file "$repo_dir/configs/etc/sddm.conf.d/10-endeavouros.conf" /etc/sddm.conf.d/10-endeavouros.conf
    copy_file "$repo_dir/configs/etc/sddm.conf.d/20-theme.conf" /etc/sddm.conf.d/20-theme.conf
    copy_file "$repo_dir/configs/etc/X11/xorg.conf.d/00-keyboard.conf" /etc/X11/xorg.conf.d/00-keyboard.conf

    copy_dir "$repo_dir/themes/sddm/Harmless-Game" /usr/share/sddm/themes/Harmless-Game
fi

if ((dry_run)); then
    printf 'Dry run completed for Ada Wong desktop config. No files were changed.\n'
else
    printf 'Installed Ada Wong desktop config. Backups use suffix .bak-%s\n' "$stamp"
fi
