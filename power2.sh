#!/bin/bash
# Interaktives Skript zur Energiespar-Konfiguration unter Debian, Ubuntu und Alpine Linux

# Farbige Ausgabe
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Kein Farbstil

# Hilfsfunktion: Stellt eine Ja/Nein-Frage
ask_question() {
  while true; do
    read -p "$1 (y/n): " yn
    case $yn in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo -e "${YELLOW}Bitte mit y oder n antworten.${NC}";;
    esac
  done
}

echo -e "${GREEN}Willkommen zum interaktiven Power Management Setup!${NC}"
echo ""
echo "Dieses Skript hilft dir dabei, den Energieverbrauch zu senken."
echo "Wir überprüfen zunächst, ob alle erforderlichen Pakete vorhanden sind."

# Erforderliche Pakete
REQUIRED_PACKAGES=(python3 pciutils git make powertop tlp)
missing_packages=()

# Fehlende Pakete ermitteln
for pkg in "${REQUIRED_PACKAGES[@]}"; do
  if ! command -v $pkg &> /dev/null; then
    missing_packages+=("$pkg")
  fi
done

if [ ${#missing_packages[@]} -gt 0 ]; then
  echo -e "${YELLOW}Folgende Pakete fehlen: ${missing_packages[*]}${NC}"
  if ask_question "Möchtest du diese fehlenden Pakete jetzt installieren?"; then
    if command -v apt-get &> /dev/null; then
      echo "Nutze apt-get..."
      sudo apt-get update
      sudo apt-get install -y "${missing_packages[@]}"
    elif command -v apk &> /dev/null; then
      echo "Nutze apk..."
      sudo apk update
      sudo apk add "${missing_packages[@]}"
    else
      echo "Kein unterstützter Paketmanager gefunden. Bitte installiere die Pakete manuell."
    fi
  else
    echo "Fortfahren ohne Installation der fehlenden Pakete."
  fi
else
  echo -e "${GREEN}Alle erforderlichen Pakete sind installiert.${NC}"
fi

echo ""
echo "============================================"
echo -e "${GREEN}Abschnitt: TLP Konfiguration${NC}"
echo "TLP kann helfen, systemweit Strom zu sparen."
if ask_question "Möchtest du TLP aktivieren und starten?"; then
  if command -v tlp &> /dev/null; then
    if command -v systemctl &> /dev/null; then
      sudo systemctl enable tlp
      sudo systemctl start tlp
      echo "TLP wurde aktiviert und gestartet."
    else
      echo "Kein systemd gefunden. Bitte starte TLP manuell."
    fi
  else
    echo "TLP ist nicht installiert."
  fi
else
  echo "TLP-Konfiguration wird übersprungen."
fi

echo ""
echo "============================================"
echo -e "${GREEN}Abschnitt: AutoASPM${NC}"
echo "AutoASPM (Python) verwaltet die ASPM-Einstellungen deiner PCIe-Geräte."
if ask_question "Möchtest du das AutoASPM Python-Skript ausführen?"; then
  AUTOASPM_DIR="$HOME/AutoASPM"
  if [ ! -d "$AUTOASPM_DIR" ]; then
    echo "Klonen von AutoASPM in $AUTOASPM_DIR..."
    git clone https://github.com/notthebee/AutoASPM.git "$AUTOASPM_DIR"
  else
    echo "AutoASPM-Verzeichnis existiert bereits. Update wird durchgeführt..."
    cd "$AUTOASPM_DIR" && git pull
  fi
  echo "Führe AutoASPM Python-Skript aus..."
  python3 "$AUTOASPM_DIR/autoaspm.py"
else
  echo "Ausführung des AutoASPM Python-Skripts wird übersprungen."
fi

echo ""
echo "============================================"
echo -e "${GREEN}Abschnitt: Powertop${NC}"
echo "Powertop zeigt dir detaillierte Informationen und Optimierungsvorschläge zum Stromverbrauch."
if ask_question "Soll Powertop am Ende gestartet werden?"; then
  sudo powertop
else
  echo "Powertop wird nicht gestartet."
fi

echo ""
echo -e "${GREEN}Energiespar-Setup abgeschlossen!${NC}"
echo "Bitte überprüfe, ob alle Dienste wie gewünscht laufen."
