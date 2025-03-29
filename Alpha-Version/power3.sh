Version 3.0

#!/bin/bash
# Interaktives Energiespar-Skript für Debian, Ubuntu und Alpine Linux
# Dieses Skript bietet ein Menü mit Optionen zur Installation und Konfiguration verschiedener Tools.

# Farbige Ausgabe (ANSI)
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Kein Farbstil

# Benötigte Pakete (Grundtools und Energiespar-Tools)
REQUIRED_PACKAGES=(python3 pciutils git make powertop tlp laptop-mode-tools auto-cpufreq cpupower thermald whiptail)

# Funktion: Fehlende Pakete ermitteln und installieren
install_missing_packages() {
  missing=()
  for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! command -v $pkg &> /dev/null; then
      missing+=("$pkg")
    fi
  done

  if [ ${#missing[@]} -gt 0 ]; then
    echo -e "${YELLOW}Folgende Pakete fehlen: ${missing[*]}${NC}"
    if whiptail --title "Paketinstallation" --yesno "Möchtest du diese fehlenden Pakete jetzt installieren?" 10 60; then
      if command -v apt-get &> /dev/null; then
        echo "Nutze apt-get..."
        sudo apt-get update
        sudo apt-get install -y "${missing[@]}"
      elif command -v apk &> /dev/null; then
        echo "Nutze apk..."
        sudo apk update
        sudo apk add "${missing[@]}"
      else
        echo -e "${RED}Kein unterstützter Paketmanager gefunden. Bitte installiere die Pakete manuell.${NC}"
        exit 1
      fi
    else
      echo "Fortfahren ohne Installation der fehlenden Pakete."
    fi
  else
    echo -e "${GREEN}Alle erforderlichen Pakete sind installiert.${NC}"
  fi
}

# Funktion: TLP aktivieren und starten
configure_tlp() {
  if command -v tlp &> /dev/null; then
    if command -v systemctl &> /dev/null; then
      sudo systemctl enable tlp
      sudo systemctl start tlp
      whiptail --title "TLP" --msgbox "TLP wurde aktiviert und gestartet." 8 60
    else
      whiptail --title "TLP" --msgbox "Kein systemd gefunden. Bitte starte TLP manuell." 8 60
    fi
  else
    whiptail --title "TLP" --msgbox "TLP ist nicht installiert." 8 60
  fi
}

# Funktion: AutoASPM Python-Skript klonen/aktualisieren und ausführen
run_autoaspm() {
  AUTOASPM_DIR="$HOME/AutoASPM"
  if [ ! -d "$AUTOASPM_DIR" ]; then
    whiptail --title "AutoASPM" --msgbox "Klonen von AutoASPM in $AUTOASPM_DIR..." 8 60
    git clone https://github.com/notthebee/AutoASPM.git "$AUTOASPM_DIR"
  else
    whiptail --title "AutoASPM" --msgbox "AutoASPM-Verzeichnis existiert bereits. Update wird durchgeführt..." 8 60
    cd "$AUTOASPM_DIR" && git pull
  fi
  whiptail --title "AutoASPM" --msgbox "Führe AutoASPM Python-Skript aus..." 8 60
  python3 "$AUTOASPM_DIR/autoaspm.py"
}

# Funktion: Powertop starten
start_powertop() {
  sudo powertop
}

# Funktion: Laptop-mode-tools konfigurieren (Anpassungen können hier erweitert werden)
configure_laptop_mode() {
  whiptail --title "Laptop-mode-tools" --msgbox "Laptop-mode-tools sind installiert. Bitte passe die Konfiguration in /etc/laptop-mode/laptop-mode.conf an, falls gewünscht." 10 60
}

# Funktion: auto-cpufreq installieren/konfigurieren
configure_auto_cpufreq() {
  if command -v auto-cpufreq &> /dev/null; then
    if whiptail --title "auto-cpufreq" --yesno "Möchtest du auto-cpufreq jetzt starten und den Energiesparmodus aktivieren?" 10 60; then
      sudo auto-cpufreq --install
      sudo auto-cpufreq --force
      whiptail --title "auto-cpufreq" --msgbox "auto-cpufreq wurde gestartet." 8 60
    else
      whiptail --title "auto-cpufreq" --msgbox "auto-cpufreq-Konfiguration übersprungen." 8 60
    fi
  else
    whiptail --title "auto-cpufreq" --msgbox "auto-cpufreq ist nicht installiert." 8 60
  fi
}

# Funktion: cpupower konfigurieren (Beispiel: aktiviere den performance Governor)
configure_cpupower() {
  if command -v cpupower &> /dev/null; then
    if whiptail --title "cpupower" --yesno "Möchtest du cpupower konfigurieren (z.B. den 'performance' Governor setzen)?" 10 60; then
      sudo cpupower frequency-set -g performance
      whiptail --title "cpupower" --msgbox "cpupower wurde konfiguriert (Governor: performance)." 8 60
    else
      whiptail --title "cpupower" --msgbox "cpupower-Konfiguration übersprungen." 8 60
    fi
  else
    whiptail --title "cpupower" --msgbox "cpupower ist nicht installiert." 8 60
  fi
}

# Funktion: thermald installieren/konfigurieren
configure_thermald() {
  if command -v thermald &> /dev/null; then
    if whiptail --title "thermald" --yesno "Möchtest du thermald starten?" 10 60; then
      sudo systemctl enable thermald
      sudo systemctl start thermald
      whiptail --title "thermald" --msgbox "thermald wurde gestartet." 8 60
    else
      whiptail --title "thermald" --msgbox "thermald-Start übersprungen." 8 60
    fi
  else
    whiptail --title "thermald" --msgbox "thermald ist nicht installiert." 8 60
  fi
}

# Überprüfen, ob whiptail installiert ist (wird für Menüs benötigt)
if ! command -v whiptail &> /dev/null; then
  echo -e "${RED}Das Paket 'whiptail' wird benötigt, um dieses Skript auszuführen.${NC}"
  exit 1
fi

# Fehlende Pakete installieren (optional)
install_missing_packages

# Endlos-Menü
while true; do
  CHOICE=$(whiptail --title "Power Management Menü" --menu "Wähle eine Option:" 22 78 10 \
    "1" "Fehlende Pakete installieren" \
    "2" "TLP aktivieren und starten" \
    "3" "AutoASPM Python-Skript ausführen" \
    "4" "Powertop starten" \
    "5" "Laptop-mode-tools konfigurieren" \
    "6" "auto-cpufreq konfigurieren/aktivieren" \
    "7" "cpupower konfigurieren" \
    "8" "thermald starten" \
    "9" "Beenden" 3>&1 1>&2 2>&3)

  case $CHOICE in
    "1")
      install_missing_packages
      ;;
    "2")
      configure_tlp
      ;;
    "3")
      run_autoaspm
      ;;
    "4")
      start_powertop
      ;;
    "5")
      configure_laptop_mode
      ;;
    "6")
      configure_auto_cpufreq
      ;;
    "7")
      configure_cpupower
      ;;
    "8")
      configure_thermald
      ;;
    "9")
      whiptail --title "Beenden" --msgbox "Das Skript wird beendet. Viel Erfolg beim Energiesparen!" 8 60
      exit 0
      ;;
    *)
      whiptail --title "Fehler" --msgbox "Ungültige Auswahl. Bitte erneut versuchen." 8 60
      ;;
  esac
done
