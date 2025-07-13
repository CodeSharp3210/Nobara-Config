#!/bin/bash

# === Configurazioni iniziali ===
CONFIG_DIR="$HOME/Nobara-Config"
mkdir -p "$CONFIG_DIR"

echo "📥 Scaricamento file nella cartella: $CONFIG_DIR"

# === Funzione per scaricare un file ===
scarica_file() {
    local url="$1"
    local output="$2"
    echo "➡️ Scarico $output..."
    curl -L -o "$CONFIG_DIR/$output" "$url"
}

# === Scaricamento dei file ===
scarica_file "https://raw.githubusercontent.com/CodeSharp3210/Nobara-Config/main/click.ogg" "click.ogg"
scarica_file "https://raw.githubusercontent.com/CodeSharp3210/Nobara-Config/main/dash-to-dock.conf" "dash-to-dock.conf"
scarica_file "https://raw.githubusercontent.com/CodeSharp3210/Nobara-Config/main/desktop-icons-ng-config.dconf" "desktop-icons-ng-config.dconf"
scarica_file "https://raw.githubusercontent.com/CodeSharp3210/Nobara-Config/main/macOS%20Tahoe%20Dark.jpg" "macOS-Tahoe-Dark.jpg"

echo "✅ File scaricati."

# === Imposta lo sfondo ===
echo "🎨 Imposto lo sfondo..."
gsettings set org.gnome.desktop.background picture-uri-dark "file://$CONFIG_DIR/macOS-Tahoe-Dark.jpg"
gsettings set org.gnome.desktop.background picture-uri "file://$CONFIG_DIR/macOS-Tahoe-Dark.jpg"

# === Verifica e installazione estensioni via Flatpak ===
echo "🧩 Controllo estensioni..."

install_extension_flatpak() {
    local ext_name="$1"
    local flatpak_name="$2"

    if ! gnome-extensions list | grep -q "$ext_name"; then
        echo "📦 Installazione estensione $ext_name via Flatpak..."
        flatpak install -y "$flatpak_name"
    else
        echo "✅ Estensione $ext_name già installata."
    fi
}

# Dash-to-Dock
install_extension_flatpak "dash-to-dock" "org.gnome.Extensions"
gnome-extensions enable dash-to-dock@micxgx.gmail.com 2>/dev/null

# Desktop Icons NG
install_extension_flatpak "desktop-icons-ng" "org.gnome.Extensions"
gnome-extensions enable ding@rastersoft.com 2>/dev/null

# === Importazione configurazioni ===
echo "🛠️ Applico configurazioni Dash-to-Dock e Desktop Icons..."

if command -v dconf &> /dev/null; then
    dconf load /org/gnome/shell/extensions/dash-to-dock/ < "$CONFIG_DIR/dash-to-dock.conf"
    dconf load /org/gnome/shell/extensions/desktop-icons-ng/ < "$CONFIG_DIR/desktop-icons-ng-config.dconf"
    echo "✅ Configurazioni applicate con successo."
else
    echo "⚠️ dconf non trovato. Non posso applicare le configurazioni."
fi

# === Modifica suono di notifica ===

echo "🔊 Modifico suono di notifica temporaneamente..."

# Imposta il suono personalizzato come notifica (usando il nome 'click')
gsettings set org.gnome.desktop.sound theme-name "gnome"
gsettings set org.gnome.desktop.sound event-sounds true

# Copia il file personalizzato nella cartella temporanea dei suoni
THEME_ALERTS_DIR="$HOME/.local/share/sounds/gnome/default/alerts"
mkdir -p "$THEME_ALERTS_DIR"

# Backup dell'originale
cp /usr/share/sounds/gnome/default/alerts/click.ogg "$CONFIG_DIR/original-click.ogg"

# Copia temporaneamente il click.ogg personalizzato nel tema di suono locale
cp "$CONFIG_DIR/click.ogg" "$THEME_ALERTS_DIR/click.ogg"

# Forza l'uso del suono 'click'
gsettings set org.gnome.desktop.sound input-feedback-sounds true

echo "🎵 Suono personalizzato 'click' attivato."

# === Sostituzione file personalizzato con quello originale ===
echo "♻️ Rimpiazzo click.ogg con versione originale..."

cp "$CONFIG_DIR/original-click.ogg" "$CONFIG_DIR/click.ogg"

# Ricarica impostazione del suono (rimane sempre "click", ma ora il file è personalizzato)
gsettings set org.gnome.desktop.sound theme-name "gnome"

echo "✅ Suono 'click' reimpostato con versione personalizzata."

echo "🎉 Configurazione completata!"
