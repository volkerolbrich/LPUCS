#!/bin/bash
# Interaktives Energiespar-Skript für Debian, Ubuntu und Alpine Linux (Version 2)
# Mit erweiterten Prüfungen, editierbarer laptop-mode-Konfiguration und flexibler cpupower-Auswahl

# Farbige Ausgabe (ANSI)
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Kein Farbstil

# Hilfsfunktion: Gibt eine Zeile-Trennung aus
print_separator() {
  echo -e "${YELLOW}============================================${NC}"
}

# Funktion: Fehlende Pakete ermitteln und optional installieren
check_and_install_packages() {
  missing=()

  # Prüfliste: [Paketname]=Befehl oder Test (falls Befehl nicht vorhanden)
  # Für laptop-mode-tools prüfen wir die Existenz der Konfigurationsdatei.
  if ! command -v python3 &> /dev/null; then missing+=("python3"); fi
  if ! command -v lspci &> /dev/null; then missing+=("pciutils"); fi
  if ! command -v git &> /dev/null; then missing+=("git"); fi
  if ! command -v make &> /dev/null; then missing+=("make"); fi
  if ! command -v powertop &> /dev/null; then missing+=("powertop"); fi
  if ! command -v tlp &> /dev/null; then missing+=("tlp"); fi
  if [ ! -f /etc/laptop-mode/laptop-mode.conf ]; then missing+=("laptop-mode-tools"); fi
  if ! command -v auto-cpufreq &> /dev/null; then missing+=("auto-cpufreq"); fi
  if ! command -v cpupower &> /dev/null; then missing+=("cpupower"); fi
  if ! command -v thermald &> /dev/null; then missing+=("thermald"); fi
  if ! command -v whiptail &> /dev/null; then missing+=("whiptail"); fi

  if [ ${#missing[@]} -gt 0 ]; then
    msg="Folgende Pakete/Komponenten fehlen oder sind nicht richtig installiert:\n\n"
    for pkg in "${missing[@]}"; do
      msg+="$pkg\n"
    done
    msg+="\nMöchtest du diese jetzt (sofern in den Repositories verfügbar) installieren?"
    if whiptail --title "Paketinstallation" --yesno "$msg" 15 60; then
      if command -v apt-get &> /dev/null; then
        echo -e "${YELLOW}Nutze apt-get zur Installation...${NC}"
        sudo apt-get update
        sudo apt-get install -y "${missing[@]}"
      elif command -v apk &> /dev/null; then
        echo -e "${YELLOW}Nutze apk zur Installation...${NC}"
        sudo apk update
        sudo apk add "${missing[@]}"
      else
        echo -e "${RED}Kein unterstützter Paketmanager gefunden. Bitte installiere die Pakete manuell.${NC}"
        exit 1
      fi
    else
      echo -e "${YELLOW}Fortfahren ohne Installation der fehlenden Pakete.${NC}"
    fi
  else
    echo -e "${GREEN}Alle erforderlichen Pakete/Komponenten sind installiert.${NC}"
  fi
  sleep 1
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

# Funktion: Laptop-mode-tools konfigurieren (mit nano editieren)
configure_laptop_mode() {
  if [ -f /etc/laptop-mode/laptop-mode.conf ]; then
    if whiptail --title "Laptop-mode-tools" --yesno "Möchtest du die Konfigurationsdatei /etc/laptop-mode/laptop-mode.conf mit nano bearbeiten?" 10 60; then
      nano /etc/laptop-mode/laptop-mode.conf
    else
      whiptail --title "Laptop-mode-tools" --msgbox "Laptop-mode-tools-Konfiguration bleibt unverändert." 8 60
    fi
  else
    whiptail --title "Laptop-mode-tools" --msgbox "Die Datei /etc/laptop-mode/laptop-mode.conf wurde nicht gefunden. Bitte installiere laptop-mode-tools." 8 60
  fi
}

# Funktion: auto-cpufreq konfigurieren/aktivieren
configure_auto_cpufreq() {
  if command -v auto-cpufreq &> /dev/null; then
    if whiptail --title "auto-cpufreq" --yesno "Möchtest du auto-cpufreq starten und den Energiesparmodus aktivieren?" 10 60; then
      sudo auto-cpufreq --install
      sudo auto-cpufreq --force
      whiptail --title "auto-cpufreq" --msgbox "auto-cpufreq wurde gestartet." 8 60
    else
      whiptail --title "auto-cpufreq" --msgbox "auto-cpufreq-Konfiguration übersprungen." 8 60
    fi
  else
    whiptail --title "auto-cpufreq" --msgbox "auto-cpufreq ist nicht installiert oder in den Repositories nicht verfügbar." 8 60
  fi
}

# Funktion: cpupower konfigurieren mit Auswahl zwischen Governor-Modi
configure_cpupower() {
  if command -v cpupower &> /dev/null; then
    MODE=$(whiptail --title "cpupower Konfiguration" --menu "Wähle den gewünschten Governor:" 15 60 3 \
      "performance" "Maximale Leistung" \
      "powersave" "Energiesparend" \
      "ondemand" "Dynamische Anpassung" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
      sudo cpupower frequency-set -g "$MODE"
      whiptail --title "cpupower" --msgbox "cpupower wurde konfiguriert (Governor: $MODE)." 8 60
    else
      whiptail --title "cpupower" --msgbox "cpupower-Konfiguration übersprungen." 8 60
    fi
  else
    whiptail --title "cpupower" --msgbox "cpupower ist nicht installiert." 8 60
  fi
}

# Funktion: thermald starten
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

# Sicherstellen, dass whiptail installiert ist
if ! command -v whiptail &> /dev/null; then
  echo -e "${RED}Das Paket 'whiptail' wird benötigt, um dieses Skript auszuführen.${NC}"
  exit 1
fi

# Initial fehlende Pakete prüfen und ggf. installieren
check_and_install_packages
print_separator
sleep 1

# Hauptmenü-Schleife
while true; do
  CHOICE=$(whiptail --title "Power Management Menü" --menu "Wähle eine Option:" 22 78 10 \
    "1" "Fehlende Pakete prüfen und installieren" \
    "2" "TLP aktivieren und starten" \
    "3" "AutoASPM Python-Skript ausführen" \
    "4" "Powertop starten" \
    "5" "Laptop-mode-tools konfigurieren (mit nano bearbeiten)" \
    "6" "auto-cpufreq konfigurieren/aktivieren" \
    "7" "cpupower konfigurieren (Governor wählen)" \
    "8" "thermald starten" \
    "9" "Beenden" 3>&1 1>&2 2>&3)

  case $CHOICE in
    "1")
      check_and_install_packages
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
  print_separator
done

