#!/bin/bash
set -e

# ============================
# Detectar usuario real y home
# ============================
if [ "$EUID" -eq 0 ]; then
    if [ -n "$SUDO_USER" ]; then
        TARGET_USER="$SUDO_USER"
    else
        read -p "Ejecutando como root. Ingresa el usuario destino para copiar archivos: " TARGET_USER
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
echo "Directorio home: $HOME_DIR"

# ============================
# Verificar sudo del usuario destino
# ============================
if ! id -nG "$TARGET_USER" | grep -qw sudo; then
    if [ "$EUID" -ne 0 ]; then
        echo "El usuario '$TARGET_USER' no tiene sudo. Ejecuta el script como root primero."
        exit 1
    else
        echo "El usuario '$TARGET_USER' no tiene sudo. Agregando al grupo sudo..."
        usermod -aG sudo "$TARGET_USER"
        echo "Usuario '$TARGET_USER' agregado al grupo sudo."
        echo "Cierra sesión y vuelve a entrar con '$TARGET_USER', luego ejecuta el script de nuevo usando sudo."
        exit 0
    fi
fi

# ============================
# Directorio del repo
# ============================
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "REPO_DIR = $REPO_DIR"

# ============================
# Menú principal
# ============================
echo "------------- Lazheart Setup -----------------"
cat <<EOF
Selecciona si es la maquina host o clone
1) Maquina Host (Guardar configuración actual al repo)
2) Maquina Clone (Instalar desde el repo)
EOF

echo -n "Selecciona una opción [1-2]: "
read -r machine_choice

case "$machine_choice" in

# ================= HOST =================
1)
    echo "========================================"
    echo " Guardando configuración al repo"
    echo "========================================"

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
            cp -r "$HOME_DIR/.${dir}/"* "$REPO_DIR/$dir/" 2>/dev/null || true
            shopt -u nullglob
            echo "✓ $dir guardados"
        fi
    done

    if [ -d "$HOME_DIR/.local/share/gnome-shell/extensions" ]; then
        shopt -s nullglob
        cp -r "$HOME_DIR/.local/share/gnome-shell/extensions/"* \
            "$REPO_DIR/gnome-extensions/" 2>/dev/null || true
        shopt -u nullglob
        echo "✓ Extensiones de GNOME guardadas"
    fi

    echo "========================================"
    echo " Configuración guardada exitosamente"
    echo "========================================"
    exit 0
;;

# ================= CLONE =================
2)
    echo "========================================"
    echo " Instalando desde el repo"
    echo "========================================"

    cat <<EOF
Escoge tu distro:
1) Ubuntu / Debian (apt)
2) Fedora (dnf)
3) Arch Linux (pacman)
4) Fedora Silverblue (rpm-ostree)
5) Salir
EOF

    echo -n "Selecciona una opción [1-5]: "
    read -r distro_choice

    case "$distro_choice" in
        1)
            sudo apt update && sudo apt upgrade -y
            sudo apt install -y git docker.io curl nodejs npm flatpak flatpak-builder \
                gnome-shell-extensions gnome-shell-extension-manager gnome-tweaks
        ;;
        2)
            sudo dnf upgrade --refresh -y
            sudo dnf install -y git docker curl nodejs npm flatpak flatpak-builder \
                gnome-shell-extensions gnome-shell-extension-manager gnome-tweaks
        ;;
        3)
            sudo pacman -S --noconfirm git docker curl nodejs npm flatpak flatpak-builder \
                gnome-shell-extensions gnome-shell-extension-manager gnome-tweaks
        ;;
        4)
            sudo rpm-ostree install git docker curl nodejs npm flatpak flatpak-builder \
                gnome-shell-extensions gnome-shell-extension-manager gnome-tweaks
            echo "Reinicia el sistema para aplicar rpm-ostree"
        ;;
        5) exit 0 ;;
        *) echo "Opción inválida"; exit 1 ;;
    esac

    sudo systemctl enable --now docker || true
    sudo usermod -aG docker "$TARGET_USER"

    echo "========================================"
    echo " Configurando Flatpak"
    echo "========================================"

    sudo flatpak remote-add --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo

    flatpak install -y flathub \
        io.github.kolunmi.Bazaar \
        org.flatpak.Builder \
        com.discordapp.Discord \
        com.heroicgameslauncher.hgl \
        org.armagetronad.ArmagetronAdvanced \
        io.github.realmazharhussain.GdmSettings || true

    echo "========================================"
    echo " Copiando archivos de aspecto"
    echo "========================================"

    mkdir -p \
        "$HOME_DIR/.themes" \
        "$HOME_DIR/.icons" \
        "$HOME_DIR/.wallpapers" \
        "$HOME_DIR/.assets" \
        "$HOME_DIR/.local/share/gnome-shell/extensions"

    shopt -s nullglob
    cp -r "$REPO_DIR/themes/"* "$HOME_DIR/.themes/" 2>/dev/null || true
    cp -r "$REPO_DIR/icons/"* "$HOME_DIR/.icons/" 2>/dev/null || true
    cp -r "$REPO_DIR/wallpapers/"* "$HOME_DIR/.wallpapers/" 2>/dev/null || true
    cp -r "$REPO_DIR/assets/"* "$HOME_DIR/.assets/" 2>/dev/null || true
    cp -r "$REPO_DIR/gnome-extensions/"* \
        "$HOME_DIR/.local/share/gnome-shell/extensions/" 2>/dev/null || true
    shopt -u nullglob

    if [ -f "$REPO_DIR/assets/yo.png" ]; then
        cp "$REPO_DIR/assets/yo.png" "$HOME_DIR/.face"
    fi

    if [ -f "$REPO_DIR/grub/2k/install.sh" ]; then
        sudo chmod +x "$REPO_DIR/grub/2k/install.sh"
        sudo bash "$REPO_DIR/grub/2k/install.sh"
    fi

    echo "========================================"
    echo " Setup completado exitosamente"
    echo "Cierra sesión para usar Docker"
    echo "========================================"
;;
*)
    echo "Opción inválida"
    exit 1
;;
esac

