#!/bin/bash
set -e

echo "------------- Lazheart Setup -----------------"

echo 'Escoge tu distro:
1) Ubuntu / Debian (apt)
2) Fedora (dnf)
3) Arch Linux (pacman)
4) Fedora Silverblue (rpm-ostree)
5) Salir'
echo -n "Selecciona una opción [1-5]: "
read distro_choice

case "$distro_choice" in
    # ---------------- APT ----------------
    1)
        echo "Ubuntu / Debian seleccionado"
        echo "Actualizando sistema..."
        sudo apt update && sudo apt upgrade -y
        echo "Instalando paquetes necesarios..."
        sudo apt install -y \
            git \
            docker.io \
            curl \
            nodejs \
            npm \
            flatpak \
            flatpak-builder
        echo "Habilitando e iniciando Docker..."
        sudo systemctl enable --now docker
        sudo usermod -aG docker "$USER"

        echo "Instalando Managers para Gnome..."
        sudo apt install -y gnome-shell-extensions
        sudo apt install -y gnome-shell-extension-manager
        sudo apt install -y gnome-tweaks
       
        ;;
    # ---------------- DNF ----------------
    2)
        echo "Fedora seleccionado"

        echo "Actualizando sistema..."
        sudo dnf upgrade --refresh -y


        echo "Instalando paquetes necesarios..."
        sudo dnf install -y \
            git \
            docker \
            curl \
            nodejs \
            npm \
            flatpak \
            flatpak-builder

        sudo systemctl enable --now docker
        sudo usermod -aG docker "$USER"
        
        echo "Instalando Managers para Gnome..."
        sudo dnf install -y gnome-shell-extensions
        sudo dnf install -y gnome-shell-extension-manager
        sudo dnf install -y gnome-tweaks
        ;;
    # ---------------- PACMAN ----------------
    3)
        echo "Arch Linux seleccionado"
        
        #echo "Actualizando sistema..."
        #sudo pacman -Syu --noconfirm

        echo "Instalando paquetes necesarios..."
        sudo pacman -S --noconfirm \
            git \
            docker \
            curl \
            nodejs \
            npm \
            flatpak \
            flatpak-builder
        echo "Habilitando e iniciando Docker..."
        sudo systemctl enable --now docker
        sudo usermod -aG docker "$USER"

        echo "Instalando Managers para Gnome..."
        sudo pacman -S --noconfirm gnome-shell-extensions
        sudo pacman -S --noconfirm gnome-shell-extension-manager
        sudo pacman -S --noconfirm gnome-tweaks

        ;;
    # ---------------- SILVERBLUE ----------------
    4)
        echo "Fedora Silverblue seleccionado"

        echo "Instalando paquetes necesarios..."
        sudo rpm-ostree install \
            git \
            docker \
            curl \
            nodejs \
            npm \
            flatpak \
            flatpak-builder

        echo " Reinicia el sistema para aplicar rpm-ostree"

        echo "Habilitando e iniciando Docker..."
        sudo systemctl enable --now docker
        sudo usermod -aG docker "$USER"

        echo "Instalando Managers para Gnome..."
        sudo rpm-ostree install gnome-shell-extensions
        sudo rpm-ostree install gnome-shell-extension-manager
        sudo rpm-ostree install gnome-tweaks
        ;;
    # ---------------- EXIT ----------------
    5)
        echo "Saliendo..."
        exit 0
        ;;
    *)
        echo "Opción inválida"
        exit 1
        ;;
    esac

# ---------------- FLATPAK ----------------
echo "Configurando Flathub..."
sudo flatpak remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

echo "----------- Suite Flatpak -----------"

flatpak install -y flathub io.github.kolunmi.Bazaar
flatpak install -y flathub org.flatpak.Builder
flatpak install -y flathub com.discordapp.Discord
flatpak install -y flathub com.heroicgameslauncher.hgl
echo "-----------Creando Grib----------------------"
flatpak install flathub org.armagetronad.ArmagetronAdvanced
echo "---------------------------------------------"

echo "----------- Creando Carpetas de Aspecto -----------"

mkdir -p "$HOME/.themes"
mkdir -p "$HOME/.icons"
mkdir -p "$HOME/.wallpapers"
mkdir -p "$HOME/.assets"

echo "----------- Clonando repositorios de aspecto -----------"

cp assets/* "$HOME/.assets/"
cp wallpapers/* "$HOME/.wallpapers/"




echo "----------- Actualizando aspecto -----------"
echo "----------- Setup completado -----------"

