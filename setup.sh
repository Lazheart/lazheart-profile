#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "------------- Lazheart Setup -----------------"
echo 'Selecciona si es la maquina host o clone
1) Maquina Host (Guardar configuración actual al repo)
2) Maquina Clone (Instalar desde el repo)'
echo -n "Selecciona una opción [1-2]: "
read machine_choice 

case "$machine_choice" in
    # ---------------- HOST ----------------
    1)
        echo "========================================"
        echo "   Guardando configuración al repo"
        echo "========================================"
        
        # Copiar iconos
        if [ -d "$HOME/.icons" ]; then
            echo "Copiando iconos..."
            cp -r "$HOME/.icons"/* "$REPO_DIR/icons/" 2>/dev/null || true
            echo "✓ Iconos guardados"
        else
            echo " Carpeta .icons no encontrada"
        fi
        
        # Copiar temas
        if [ -d "$HOME/.themes" ]; then
            echo "Copiando temas..."
            cp -r "$HOME/.themes"/* "$REPO_DIR/themes/" 2>/dev/null || true
            echo "✓ Temas guardados"
        else
            echo " Carpeta .themes no encontrada"
        fi
        
        # Copiar wallpapers
        if [ -d "$HOME/.wallpapers" ]; then
            echo "Copiando wallpapers..."
            cp -r "$HOME/.wallpapers"/* "$REPO_DIR/wallpapers/" 2>/dev/null || true
            echo "✓ Wallpapers guardados"
        else
            echo " Carpeta .wallpapers no encontrada"
        fi
        
        # Copiar assets
        if [ -d "$HOME/.assets" ]; then
            echo "Copiando assets..."
            cp -r "$HOME/.assets"/* "$REPO_DIR/assets/" 2>/dev/null || true
            echo "✓ Assets guardados"
        else
            echo " Carpeta .assets no encontrada"
        fi
        
        # Copiar extensiones de GNOME
        if [ -d "$HOME/.local/share/gnome-shell/extensions" ]; then
            echo "Copiando extensiones de GNOME..."
            mkdir -p "$REPO_DIR/gnome-extensions"
            cp -r "$HOME/.local/share/gnome-shell/extensions"/* "$REPO_DIR/gnome-extensions/" 2>/dev/null || true
            echo "✓ Extensiones de GNOME guardadas"
        else
            echo " Carpeta de extensiones de GNOME no encontrada"
        fi
        
        echo "========================================"
        echo "   Configuración guardada exitosamente"
        echo "========================================"
        exit 0
        ;;
    
    # ---------------- CLONE ----------------
    2)
        echo "========================================"
        echo "   Instalando desde el repo"
        echo "========================================"
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
                sudo apt install -y \
                    gnome-shell-extensions \
                    gnome-shell-extension-manager \
                    gnome-tweaks
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

                echo "Habilitando e iniciando Docker..."
                sudo systemctl enable --now docker
                sudo usermod -aG docker "$USER"
                
                echo "Instalando Managers para Gnome..."
                sudo dnf install -y \
                    gnome-shell-extensions \
                    gnome-shell-extension-manager \
                    gnome-tweaks
                ;;
            
            # ---------------- PACMAN ----------------
            3)
                echo "Arch Linux seleccionado"
                
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
                sudo pacman -S --noconfirm \
                    gnome-shell-extensions \
                    gnome-shell-extension-manager \
                    gnome-tweaks
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
                    flatpak-builder \
                    gnome-shell-extensions \
                    gnome-shell-extension-manager \
                    gnome-tweaks

                echo " Reinicia el sistema para aplicar los cambios de rpm-ostree"
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
        esac
        
        # ---------------- FLATPAK ----------------
        echo ""
        echo "========================================"
        echo "   Configurando Flatpak"
        echo "========================================"
        sudo flatpak remote-add --if-not-exists flathub \
            https://dl.flathub.org/repo/flathub.flatpakrepo

        echo "Instalando aplicaciones Flatpak..."
        flatpak install -y flathub io.github.kolunmi.Bazaar
        flatpak install -y flathub org.flatpak.Builder
        flatpak install -y flathub com.discordapp.Discord
        flatpak install -y flathub com.heroicgameslauncher.hgl
        flatpak install -y flathub org.armagetronad.ArmagetronAdvanced
        echo "✓ Aplicaciones Flatpak instaladas"

        # ---------------- CARPETAS DE ASPECTO ----------------
        echo ""
        echo "========================================"
        echo "   Creando carpetas de aspecto"
        echo "========================================"
        mkdir -p "$HOME/.themes"
        mkdir -p "$HOME/.icons"
        mkdir -p "$HOME/.wallpapers"
        mkdir -p "$HOME/.assets"
        echo " Carpetas creadas"

        # ---------------- COPIANDO ARCHIVOS ----------------
        echo ""
        echo "========================================"
        echo "   Copiando archivos de aspecto"
        echo "========================================"
        
        if [ -d "$REPO_DIR/assets" ]; then
            cp -r "$REPO_DIR/assets"/* "$HOME/.assets/" 2>/dev/null || true
            echo " Assets copiados"
        fi
        
        if [ -d "$REPO_DIR/wallpapers" ]; then
            cp -r "$REPO_DIR/wallpapers"/* "$HOME/.wallpapers/" 2>/dev/null || true
            echo " Wallpapers copiados"
        fi
        
        if [ -d "$REPO_DIR/themes" ]; then
            cp -r "$REPO_DIR/themes"/* "$HOME/.themes/" 2>/dev/null || true
            echo " Temas copiados"
        fi
        
        if [ -d "$REPO_DIR/icons" ]; then
            cp -r "$REPO_DIR/icons"/* "$HOME/.icons/" 2>/dev/null || true
            echo "Iconos copiados"
        fi
        
        if [ -d "$REPO_DIR/gnome-extensions" ]; then
            mkdir -p "$HOME/.local/share/gnome-shell/extensions"
            cp -r "$REPO_DIR/gnome-extensions"/* "$HOME/.local/share/gnome-shell/extensions/" 2>/dev/null || true
            echo "Extensiones de GNOME copiadas"
        fi
        
        # ---------------Foto de user----------------------
        echo "Seteando foto de usuario..."
        if [ -f "$REPO_DIR/assets/yo.png" ]; then
            cp "$REPO_DIR/assets/yo.png" "$HOME/.face"
            echo " Foto de usuario seteada"
        else
            echo " Archivo de foto de usuario no encontrado"
        fi

        # ---------------- GRUB ----------------
        echo ""
        echo "========================================"
        echo "   Aplicando tema GRUB"
        echo "========================================"
        if [ -f "$REPO_DIR/grub/2k/install.sh" ]; then
            sudo chmod +x "$REPO_DIR/grub/2k/install.sh"
            sudo bash "$REPO_DIR/grub/2k/install.sh"
            echo "✓ Tema GRUB aplicado"
        fi

        echo "========================================"
        echo "   Setup completado exitosamente"
        echo "========================================"
        ;;
    
    *)
        echo "Opción inválida"
        exit 1
        ;;
esac

