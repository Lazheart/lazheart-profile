#!/bin/bash

set -e

echo "Actualizando el sistema..."
sudo apt get update && sudo apt upgrade -y

echo "Instalando herramientas de desarrollo..."
sudo apt install -y git docker.io curl node nodejs npm  
echo "Instalación completa."
echo "Configurando Docker para ejecutarse sin sudo..."
sudo usermod -aG docker $USER
newgrp docker
echo "Cambios aplicados."
echo "Instalando flatpak [bazar y builder]..."
sudo apt install -y flatpak
echo "Agregando repositorio de flathub..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
echo "Instalación de flatpak completa."
echo "-----------Suite de flatpak--------------"
echo "Instalando bazar desde flathub..."
flatpak install flathub io.github.kolunmi.Bazaar -y
echo "Bazar instalado."
echo "Instalando builder desde flathub..."
flatpak install flathub org.flatpak.Builder -y
echo "Builder instalado."
flatpak install flathub com.discordapp.Discord -y
echo "Discord instalado."
echo "Instalando Heroic Games Launcher"
flatpak install flathub com.heroicgameslauncher.hgl -y
echo "Heroic Games Launcher instalado."
echo "-----------Fin de la suite de flatpak--------------"

