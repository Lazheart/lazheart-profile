#!/usr/bin/env bash
set -euo pipefail

# ============================
# Detectar usuario real y home
# ============================
if [ "$EUID" -eq 0 ]; then
    if [ -n "${SUDO_USER:-}" ]; then
        TARGET_USER="$SUDO_USER"
    else
        read -rp "Ejecutando como root. Ingresa el usuario destino: " TARGET_USER
        if ! id "$TARGET_USER" &>/dev/null; then
            echo "El usuario '$TARGET_USER' no existe."
            exit 1
        fi
    fi
else
    TARGET_USER="$USER"
fi

HOME_DIR=$(eval echo "~$TARGET_USER")

echo "Usuario destino: $TARGET_USER"
echo "Home: $HOME_DIR"

# ============================
# Verificar permisos admin
# ============================
echo "Verificando permisos..."

HAS_ADMIN=false
if id -nG "$TARGET_USER" | grep -qwE "sudo|wheel"; then
    HAS_ADMIN=true
fi

if [ "$HAS_ADMIN" = false ]; then
    echo "========================================="
    echo "El usuario '$TARGET_USER' no tiene permisos de administrador."
    echo "Ejecuta como root:"
    if getent group sudo &>/dev/null; then
        echo "  usermod -aG sudo $TARGET_USER"
    elif getent group wheel &>/dev/null; then
        echo "  usermod -aG wheel $TARGET_USER"
    else
        echo "No existe grupo sudo ni wheel."
    fi
    echo "Luego reinicia sesión."
    exit 1
fi

echo "✓ Permisos confirmados"

# ============================
# Directorio del repo
# ============================
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "REPO_DIR = $REPO_DIR"

if [ ! -d "$REPO_DIR" ]; then
    echo "No se pudo determinar el directorio del repo."
    exit 1
fi

# ============================
# Menú principal
# ============================
echo "------------- Lazheart Setup -----------------"
echo "1) Maquina Host (Guardar configuración)"
echo "2) Maquina Clone (Instalar desde repo)"
read -rp "Selecciona [1-2]: " machine_choice

case "$machine_choice" in

# ================= HOST =================
1)
    echo "Guardando configuración..."

    mkdir -p \
        "$REPO_DIR/icons" \
        "$REPO_DIR/themes" \
        "$REPO_DIR/wallpapers" \
        "$REPO_DIR/assets" \
        "$REPO_DIR/gnome-extensions"

    for dir in icons themes wallpapers assets; do
        if [ -d "$HOME_DIR/.${dir}" ]; then
            echo "Copiando $dir..."
            shopt -s nullglob
            cp -r "$HOME_DIR/.${dir}/"* "$REPO_DIR/$dir/" || true
            shopt -u nullglob
        fi
    done

    if [ -d "$HOME_DIR/.local/share/gnome-shell/extensions" ]; then
        shopt -s nullglob
        cp -r "$HOME_DIR/.local/share/gnome-shell/extensions/"* \
            "$REPO_DIR/gnome-extensions/" || true
        shopt -u nullglob
    fi

    echo "Configuración guardada correctamente."
    ;;

# ================= CLONE =================
2)
    echo "Instalando desde repo..."

    echo "1) Ubuntu / Debian"
    echo "2) Arch Linux"
    echo "3) Salir"
    read -rp "Selecciona [1-3]: " distro_choice

    case "$distro_choice" in
        1)
            sudo apt update && sudo apt upgrade -y
            sudo apt install -y \
                git \
                docker.io  \
                curl nodejs npm \
                openjdk-21-jdk maven \
                flatpak flatpak-builder \
                gnome-shell-extensions \
                gnome-shell-extension-manager \
                gnome-tweaks
        ;;
        2)
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm \
                git docker curl nodejs npm \
                jdk-openjdk maven \
                flatpak flatpak-builder \
                gnome-shell-extensions \
                gnome-shell-extension-manager \
                gnome-tweaks
        ;;
        3) exit 0 ;;
        *) echo "Opción inválida"; exit 1 ;;
    esac

    # Docker
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$TARGET_USER"

    # Flatpak
    sudo flatpak remote-add --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo

    flatpak install -y flathub \
        io.github.kolunmi.Bazaar \
        org.flatpak.Builder \
        com.discordapp.Discord \
        com.heroicgameslauncher.hgl \
        org.armagetronad.ArmagetronAdvanced \
        com.google.Chrome \
        com.stremio.Stremio \
        md.obsidian.Obsidian \
        io.github.realmazharhussain.GdmSettings || true

    # Copiar archivos visuales
    mkdir -p \
        "$HOME_DIR/.themes" \
        "$HOME_DIR/.icons" \
        "$HOME_DIR/.wallpapers" \
        "$HOME_DIR/.assets" \
        "$HOME_DIR/.local/share/gnome-shell/extensions"

    shopt -s nullglob
    cp -r "$REPO_DIR/themes/"* "$HOME_DIR/.themes/" || true
    cp -r "$REPO_DIR/icons/"* "$HOME_DIR/.icons/" || true
    cp -r "$REPO_DIR/wallpapers/"* "$HOME_DIR/.wallpapers/" || true
    cp -r "$REPO_DIR/assets/"* "$HOME_DIR/.assets/" || true
    cp -r "$REPO_DIR/gnome-extensions/"* \
        "$HOME_DIR/.local/share/gnome-shell/extensions/" || true
    shopt -u nullglob

    # Permisos correctos
    sudo chown -R "$TARGET_USER":"$TARGET_USER" \
        "$HOME_DIR/.themes" \
        "$HOME_DIR/.icons" \
        "$HOME_DIR/.wallpapers" \
        "$HOME_DIR/.assets" \
        "$HOME_DIR/.local/share/gnome-shell/extensions"

    # Imagen de perfil
    if [ -f "$REPO_DIR/assets/yo.png" ]; then
        cp "$REPO_DIR/assets/yo.png" "$HOME_DIR/.face"
        sudo chown "$TARGET_USER":"$TARGET_USER" "$HOME_DIR/.face"
    fi

    # Script GRUB opcional
    if [ -f "$REPO_DIR/grub/2k/install.sh" ]; then
        sudo chmod +x "$REPO_DIR/grub/2k/install.sh"
        sudo bash "$REPO_DIR/grub/2k/install.sh"
    fi

    echo "Setup completado."
    echo "Reiniciando en 5 segundos..."
    sleep 5
    sudo reboot
    ;;
*)
    echo "Opción inválida"
    exit 1
;;
esac
