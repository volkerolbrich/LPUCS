#!/bin/bash
# Skript zur Installation und Konfiguration von Energiespar-Tools unter Debian, Ubuntu und Alpine Linux

set -e  # Beende das Skript bei Fehlern

echo "Starte Power-Save Setup für Debian, Ubuntu und Alpine Linux..."

# Funktion zur Installation von Paketen, je nach Distribution
install_packages() {
    packages=("$@")
    if command -v apt-get &> /dev/null; then
        echo "Nutze apt-get zur Installation..."
        sudo apt-get update
        sudo apt-get install -y "${packages[@]}"
    elif command -v apk &> /dev/null; then
        echo "Nutze apk zur Installation..."
        sudo apk update
        sudo apk add "${packages[@]}"
    else
        echo "Unbekannte Distribution! Bitte installiere folgende Pakete manuell: ${packages[*]}"
        exit 1
    fi
}

# Benötigte Pakete für die Energiespar-Optimierung
BASIS_PACKAGES=(git make)
ENERGY_PACKAGES=(powertop tlp)

echo "Installiere notwendige Pakete..."
install_packages "${BASIS_PACKAGES[@]}"
install_packages "${ENERGY_PACKAGES[@]}"

# TLP aktivieren (Debian & Ubuntu haben systemd, Alpine nicht)
if command -v tlp &> /dev/null; then
    echo "Aktiviere und starte TLP..."
    if command -v systemctl &> /dev/null; then
        sudo systemctl enable tlp
        sudo systemctl start tlp
    else
        echo "Kein systemd gefunden – Stelle sicher, dass TLP manuell gestartet wird!"
    fi
fi

# AutoASPM aus GitHub klonen
AUTOASPM_DIR="$HOME/AutoASPM"
if [ ! -d "$AUTOASPM_DIR" ]; then
    echo "Klonen von AutoASPM in $AUTOASPM_DIR..."
    git clone https://github.com/notthebee/AutoASPM.git "$AUTOASPM_DIR"
else
    echo "AutoASPM-Verzeichnis existiert bereits, update wird durchgeführt..."
    cd "$AUTOASPM_DIR" && git pull
fi

# AutoASPM bauen und ggf. ausführen
if [ -f "$AUTOASPM_DIR/Makefile" ]; then
    echo "Baue AutoASPM..."
    cd "$AUTOASPM_DIR"
    make
    # Falls AutoASPM eine Installation erfordert, kann hier "sudo make install" eingefügt werden
fi

# Starte AutoASPM falls möglich
if [ -x "$AUTOASPM_DIR/autoaspm.sh" ]; then
    echo "Starte AutoASPM..."
    sudo "$AUTOASPM_DIR/autoaspm.sh" &
else
    echo "Kein ausführbares Startskript in AutoASPM gefunden."
fi

echo "Energiespar-Setup abgeschlossen. Überprüfe, ob alle Dienste korrekt laufen."

# Hinweise:
# - Powertop kann mit 'sudo powertop' ausgeführt werden, um den Status zu prüfen.
# - Falls du noch aggressivere Energiesparmaßnahmen möchtest, können zusätzliche Kernel-Parameter oder CPU-Frequenzsteuerungen gesetzt werden.

