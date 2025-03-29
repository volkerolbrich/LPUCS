#!/bin/bash
# Linux Power Utils Collection Script (LPUCS) V6.1
# (c)2025 Adam´87 & Emma

# ANSI-Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Kein Farbstil

# Prüfe, ob wir als root laufen, und setze SUDO entsprechend
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# ASCII-Logo
logo="
▓█████        ▄████       ▄▄▄           
▓█   ▀       ██▒ ▀█▒     ▒████▄         
▒███        ▒██░▄▄▄░     ▒██  ▀█▄       
▒▓█  ▄      ░▓█  ██▓     ░██▄▄▄▄██      
░▒████▒ ██▓ ░▒▓███▀▒ ██▓  ▓█   ▓██▒ ██▓ 
░░ ▒░ ░ ▒▓▒  ░▒   ▒  ▒▓▒  ▒▒   ▓▒█░ ▒▓▒ 
 ░ ░  ░ ░▒    ░   ░  ░▒    ▒   ▒▒ ░ ░▒  
   ░    ░   ░ ░   ░  ░     ░   ▒    ░   
   ░  ░  ░        ░   ░        ░  ░  ░  
         ░            ░              ░   
"

################################################################################
# Startseite und Sprachwahl
################################################################################

start_page() {
  clear
  echo -e "${GREEN}$logo${NC}"
  echo ""
  echo -e "${YELLOW}E.G.A. Presents:${NC}"
  echo -e "${YELLOW}Linux Power Utils Collection Script (LPUCS) V6.1${NC}"
  echo -e "${YELLOW}(c)2025 Adam´87 & Emma${NC}"
  echo ""
  echo -e "${YELLOW}Press (G)erman, (E)nglish or e(X)it${NC}"
  read -n1 -r lang_choice
  echo ""
  case "$(echo "$lang_choice" | tr '[:lower:]' '[:upper:]')" in
    G) main_de ;;
    E) main_en ;;
    X) echo -e "${YELLOW}Exiting...${NC}" && exit 0 ;;
    *) echo -e "${RED}Ungültige Auswahl. Versuche es erneut.${NC}" && start_page ;;
  esac
}

################################################################################
# DEUTSCHE VERSION
################################################################################

# Funktion: Trennlinie (DE)
print_separator_de() {
  echo -e "${YELLOW}============================================${NC}"
}

# Funktion: Fehlende Pakete prüfen und installieren (DE)
check_and_install_packages_de() {
  missing=()
  other_missing=()
  # Standardprüfungen
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
      # Spezielle Behandlung: auto-cpufreq und laptop-mode-tools
      for pkg in "${missing[@]}"; do
        if [ "$pkg" == "auto-cpufreq" ]; then
          install_auto_cpufreq_from_git_de
        elif [ "$pkg" == "laptop-mode-tools" ]; then
          install_laptop_mode_tools_from_git_de
        else
          other_missing+=("$pkg")
        fi
      done
      if [ ${#other_missing[@]} -gt 0 ]; then
        if command -v apt-get &> /dev/null; then
          echo -e "${YELLOW}Nutze apt-get zur Installation: ${other_missing[*]}${NC}"
          $SUDO apt-get update
          $SUDO apt-get install -y "${other_missing[@]}"
        elif command -v apk &> /dev/null; then
          echo -e "${YELLOW}Nutze apk zur Installation: ${other_missing[*]}${NC}"
          $SUDO apk update
          $SUDO apk add "${other_missing[@]}"
        else
          echo -e "${RED}Kein unterstützter Paketmanager gefunden. Bitte installiere die Pakete manuell.${NC}"
          exit 1
        fi
      fi
    else
      echo -e "${YELLOW}Fortfahren ohne Installation der fehlenden Pakete.${NC}"
    fi
  else
    echo -e "${GREEN}Alle erforderlichen Pakete/Komponenten sind installiert.${NC}"
  fi
  sleep 1
}

# Funktion: Installation von auto-cpufreq aus GitHub (DE)
install_auto_cpufreq_from_git_de() {
  if whiptail --title "Installation auto-cpufreq" --yesno "Möchtest du auto-cpufreq aus dem GitHub Repository installieren?\n\nBefehl: git clone https://github.com/AdnanHodzic/auto-cpufreq.git && cd auto-cpufreq && $SUDO ./auto-cpufreq-installer" 12 70; then
    git clone https://github.com/AdnanHodzic/auto-cpufreq.git /tmp/auto-cpufreq
    cd /tmp/auto-cpufreq || exit
    $SUDO ./auto-cpufreq-installer
    cd - > /dev/null || exit
    whiptail --title "auto-cpufreq" --msgbox "auto-cpufreq wurde installiert." 8 60
  else
    whiptail --title "auto-cpufreq" --msgbox "Installation von auto-cpufreq übersprungen." 8 60
  fi
}

# Funktion: Installation von laptop-mode-tools aus GitHub (DE)
install_laptop_mode_tools_from_git_de() {
  if whiptail --title "Installation laptop-mode-tools" --yesno "Möchtest du laptop-mode-tools aus dem GitHub Repository installieren?\n\nBefehl: git clone https://github.com/rickysarraf/laptop-mode-tools.git && cd laptop-mode-tools && $SUDO ./install.sh" 12 70; then
    git clone https://github.com/rickysarraf/laptop-mode-tools.git /tmp/laptop-mode-tools
    cd /tmp/laptop-mode-tools || exit
    $SUDO ./install.sh
    cd - > /dev/null || exit
    whiptail --title "laptop-mode-tools" --msgbox "laptop-mode-tools wurde installiert." 8 60
  else
    whiptail --title "laptop-mode-tools" --msgbox "Installation von laptop-mode-tools übersprungen." 8 60
  fi
}

# Funktion: TLP aktivieren und starten (DE)
configure_tlp_de() {
  if command -v tlp &> /dev/null; then
    if command -v systemctl &> /dev/null; then
      $SUDO systemctl enable tlp
      $SUDO systemctl start tlp
      whiptail --title "TLP" --msgbox "TLP wurde aktiviert und gestartet." 8 60
    else
      whiptail --title "TLP" --msgbox "Kein systemd gefunden. Bitte starte TLP manuell." 8 60
    fi
  else
    whiptail --title "TLP" --msgbox "TLP ist nicht installiert." 8 60
  fi
}

# Funktion: AutoASPM Python-Skript klonen/aktualisieren und ausführen (DE)
run_autoaspm_de() {
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

# Funktion: Powertop starten (DE)
start_powertop_de() {
  $SUDO powertop
}

# Funktion: Laptop-mode-tools konfigurieren (mit nano bearbeiten) (DE)
configure_laptop_mode_de() {
  if [ -f /etc/laptop-mode/laptop-mode.conf ]; then
    if whiptail --title "Laptop-mode-tools" --yesno "Möchtest du die Konfigurationsdatei /etc/laptop-mode/laptop-mode.conf mit nano bearbeiten?" 10 60; then
      nano /etc/laptop-mode/laptop-mode.conf
    else
      whiptail --title "Laptop-mode-tools" --msgbox "Laptop-mode-tools-Konfiguration bleibt unverändert." 8 60
    fi
  else
    whiptail --title "Laptop-mode-tools" --msgbox "Die Datei /etc/laptop-mode/laptop-mode.conf wurde nicht gefunden." 8 60
  fi
}

# Funktion: auto-cpufreq konfigurieren/aktivieren (DE)
configure_auto_cpufreq_de() {
  if command -v auto-cpufreq &> /dev/null; then
    if whiptail --title "auto-cpufreq" --yesno "Möchtest du auto-cpufreq starten und den Energiesparmodus aktivieren?" 10 60; then
      $SUDO auto-cpufreq --install
      $SUDO auto-cpufreq --force
      whiptail --title "auto-cpufreq" --msgbox "auto-cpufreq wurde gestartet." 8 60
    else
      whiptail --title "auto-cpufreq" --msgbox "auto-cpufreq-Konfiguration übersprungen." 8 60
    fi
  else
    whiptail --title "auto-cpufreq" --msgbox "auto-cpufreq ist nicht installiert." 8 60
  fi
}

# Funktion: cpupower konfigurieren (Governor wählen) (DE)
configure_cpupower_de() {
  if command -v cpupower &> /dev/null; then
    MODE=$(whiptail --title "cpupower Konfiguration" --menu "Wähle den gewünschten Governor:" 15 60 3 \
      "performance" "Maximale Leistung" \
      "powersave" "Energiesparend" \
      "ondemand" "Dynamische Anpassung" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
      $SUDO cpupower frequency-set -g "$MODE"
      whiptail --title "cpupower" --msgbox "cpupower wurde konfiguriert (Governor: $MODE)." 8 60
    else
      whiptail --title "cpupower" --msgbox "cpupower-Konfiguration übersprungen." 8 60
    fi
  else
    whiptail --title "cpupower" --msgbox "cpupower ist nicht installiert." 8 60
  fi
}

# Funktion: thermald starten (DE)
configure_thermald_de() {
  if command -v thermald &> /dev/null; then
    if whiptail --title "thermald" --yesno "Möchtest du thermald starten?" 10 60; then
      $SUDO systemctl enable thermald
      $SUDO systemctl start thermald
      whiptail --title "thermald" --msgbox "thermald wurde gestartet." 8 60
    else
      whiptail --title "thermald" --msgbox "thermald-Start übersprungen." 8 60
    fi
  else
    whiptail --title "thermald" --msgbox "thermald ist nicht installiert." 8 60
  fi
}

# Hauptmenü (DE)
main_menu_de() {
  while true; do
    CHOICE=$(whiptail --title "Power Management Menü (DE)" --menu "Wähle eine Option:" 22 78 10 \
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
      "1") check_and_install_packages_de ;;
      "2") configure_tlp_de ;;
      "3") run_autoaspm_de ;;
      "4") start_powertop_de ;;
      "5") configure_laptop_mode_de ;;
      "6") configure_auto_cpufreq_de ;;
      "7") configure_cpupower_de ;;
      "8") configure_thermald_de ;;
      "9")
         whiptail --title "Beenden" --msgbox "Das Skript wird beendet. Viel Erfolg beim Energiesparen!" 8 60
         exit 0 ;;
      *) whiptail --title "Fehler" --msgbox "Ungültige Auswahl. Bitte erneut versuchen." 8 60 ;;
    esac
    print_separator_de
  done
}

# Hauptfunktion (DE)
main_de() {
  check_and_install_packages_de
  print_separator_de
  main_menu_de
}

################################################################################
# ENGLISCHE VERSION
################################################################################

# Funktion: Trennlinie (EN)
print_separator_en() {
  echo -e "${YELLOW}============================================${NC}"
}

# Funktion: Check and install packages (EN)
check_and_install_packages_en() {
  missing=()
  other_missing=()
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
    msg="The following packages/components are missing or not properly installed:\n\n"
    for pkg in "${missing[@]}"; do
      msg+="$pkg\n"
    done
    msg+="\nDo you want to install them now (if available in your repositories)?"
    if whiptail --title "Package Installation" --yesno "$msg" 15 60; then
      for pkg in "${missing[@]}"; do
        if [ "$pkg" == "auto-cpufreq" ]; then
          install_auto_cpufreq_from_git_en
        elif [ "$pkg" == "laptop-mode-tools" ]; then
          install_laptop_mode_tools_from_git_en
        else
          other_missing+=("$pkg")
        fi
      done
      if [ ${#other_missing[@]} -gt 0 ]; then
        if command -v apt-get &> /dev/null; then
          echo -e "${YELLOW}Using apt-get to install: ${other_missing[*]}${NC}"
          $SUDO apt-get update
          $SUDO apt-get install -y "${other_missing[@]}"
        elif command -v apk &> /dev/null; then
          echo -e "${YELLOW}Using apk to install: ${other_missing[*]}${NC}"
          $SUDO apk update
          $SUDO apk add "${other_missing[@]}"
        else
          echo -e "${RED}No supported package manager found. Please install packages manually.${NC}"
          exit 1
        fi
      fi
    else
      echo -e "${YELLOW}Proceeding without installing missing packages.${NC}"
    fi
  else
    echo -e "${GREEN}All required packages/components are installed.${NC}"
  fi
  sleep 1
}

# Function: Install auto-cpufreq from GitHub (EN)
install_auto_cpufreq_from_git_en() {
  if whiptail --title "Install auto-cpufreq" --yesno "Do you want to install auto-cpufreq from the GitHub repository?\n\nCommand: git clone https://github.com/AdnanHodzic/auto-cpufreq.git && cd auto-cpufreq && $SUDO ./auto-cpufreq-installer" 12 70; then
    git clone https://github.com/AdnanHodzic/auto-cpufreq.git /tmp/auto-cpufreq
    cd /tmp/auto-cpufreq || exit
    $SUDO ./auto-cpufreq-installer
    cd - > /dev/null || exit
    whiptail --title "auto-cpufreq" --msgbox "auto-cpufreq has been installed." 8 60
  else
    whiptail --title "auto-cpufreq" --msgbox "Installation of auto-cpufreq skipped." 8 60
  fi
}

# Function: Install laptop-mode-tools from GitHub (EN)
install_laptop_mode_tools_from_git_en() {
  if whiptail --title "Install laptop-mode-tools" --yesno "Do you want to install laptop-mode-tools from the GitHub repository?\n\nCommand: git clone https://github.com/rickysarraf/laptop-mode-tools.git && cd laptop-mode-tools && $SUDO ./install.sh" 12 70; then
    git clone https://github.com/rickysarraf/laptop-mode-tools.git /tmp/laptop-mode-tools
    cd /tmp/laptop-mode-tools || exit
    $SUDO ./install.sh
    cd - > /dev/null || exit
    whiptail --title "laptop-mode-tools" --msgbox "laptop-mode-tools has been installed." 8 60
  else
    whiptail --title "laptop-mode-tools" --msgbox "Installation of laptop-mode-tools skipped." 8 60
  fi
}

# Funktion: TLP aktivieren und starten (EN)
configure_tlp_en() {
  if command -v tlp &> /dev/null; then
    if command -v systemctl &> /dev/null; then
      $SUDO systemctl enable tlp
      $SUDO systemctl start tlp
      whiptail --title "TLP" --msgbox "TLP has been enabled and started." 8 60
    else
      whiptail --title "TLP" --msgbox "No systemd found. Please start TLP manually." 8 60
    fi
  else
    whiptail --title "TLP" --msgbox "TLP is not installed." 8 60
  fi
}

# Function: Run AutoASPM (EN)
run_autoaspm_en() {
  AUTOASPM_DIR="$HOME/AutoASPM"
  if [ ! -d "$AUTOASPM_DIR" ]; then
    whiptail --title "AutoASPM" --msgbox "Cloning AutoASPM into $AUTOASPM_DIR..." 8 60
    git clone https://github.com/notthebee/AutoASPM.git "$AUTOASPM_DIR"
  else
    whiptail --title "AutoASPM" --msgbox "AutoASPM directory exists. Pulling update..." 8 60
    cd "$AUTOASPM_DIR" && git pull
  fi
  whiptail --title "AutoASPM" --msgbox "Running AutoASPM Python script..." 8 60
  python3 "$AUTOASPM_DIR/autoaspm.py"
}

# Function: Start Powertop (EN)
start_powertop_en() {
  $SUDO powertop
}

# Function: Configure laptop-mode-tools (edit with nano) (EN)
configure_laptop_mode_en() {
  if [ -f /etc/laptop-mode/laptop-mode.conf ]; then
    if whiptail --title "laptop-mode-tools" --yesno "Do you want to edit /etc/laptop-mode/laptop-mode.conf with nano?" 10 60; then
      nano /etc/laptop-mode/laptop-mode.conf
    else
      whiptail --title "laptop-mode-tools" --msgbox "Laptop-mode-tools configuration remains unchanged." 8 60
    fi
  else
    whiptail --title "laptop-mode-tools" --msgbox "File /etc/laptop-mode/laptop-mode.conf not found." 8 60
  fi
}

# Function: Configure auto-cpufreq (EN)
configure_auto_cpufreq_en() {
  if command -v auto-cpufreq &> /dev/null; then
    if whiptail --title "auto-cpufreq" --yesno "Do you want to start auto-cpufreq to enable power saving mode?" 10 60; then
      $SUDO auto-cpufreq --install
      $SUDO auto-cpufreq --force
      whiptail --title "auto-cpufreq" --msgbox "auto-cpufreq has been started." 8 60
    else
      whiptail --title "auto-cpufreq" --msgbox "auto-cpufreq configuration skipped." 8 60
    fi
  else
    whiptail --title "auto-cpufreq" --msgbox "auto-cpufreq is not installed." 8 60
  fi
}

# Function: Configure cpupower (choose governor) (EN)
configure_cpupower_en() {
  if command -v cpupower &> /dev/null; then
    MODE=$(whiptail --title "cpupower Configuration" --menu "Choose the desired governor:" 15 60 3 \
      "performance" "Maximum Performance" \
      "powersave" "Power Saving" \
      "ondemand" "Dynamic Adjustment" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
      $SUDO cpupower frequency-set -g "$MODE"
      whiptail --title "cpupower" --msgbox "cpupower configured (Governor: $MODE)." 8 60
    else
      whiptail --title "cpupower" --msgbox "cpupower configuration skipped." 8 60
    fi
  else
    whiptail --title "cpupower" --msgbox "cpupower is not installed." 8 60
  fi
}

# Function: Start thermald (EN)
configure_thermald_en() {
  if command -v thermald &> /dev/null; then
    if whiptail --title "thermald" --yesno "Do you want to start thermald?" 10 60; then
      $SUDO systemctl enable thermald
      $SUDO systemctl start thermald
      whiptail --title "thermald" --msgbox "thermald has been started." 8 60
    else
      whiptail --title "thermald" --msgbox "thermald start skipped." 8 60
    fi
  else
    whiptail --title "thermald" --msgbox "thermald is not installed." 8 60
  fi
}

# Hauptmenü (EN)
main_menu_en() {
  while true; do
    CHOICE=$(whiptail --title "Power Management Menu (EN)" --menu "Choose an option:" 22 78 10 \
      "1" "Check and install missing packages" \
      "2" "Enable and start TLP" \
      "3" "Run AutoASPM Python script" \
      "4" "Start Powertop" \
      "5" "Configure laptop-mode-tools (edit with nano)" \
      "6" "Configure/activate auto-cpufreq" \
      "7" "Configure cpupower (choose governor)" \
      "8" "Start thermald" \
      "9" "Exit" 3>&1 1>&2 2>&3)
    case $CHOICE in
      "1") check_and_install_packages_en ;;
      "2") configure_tlp_en ;;
      "3") run_autoaspm_en ;;
      "4") start_powertop_en ;;
      "5") configure_laptop_mode_en ;;
      "6") configure_auto_cpufreq_en ;;
      "7") configure_cpupower_en ;;
      "8") configure_thermald_en ;;
      "9")
         whiptail --title "Exit" --msgbox "Exiting. Good luck with power saving!" 8 60
         exit 0 ;;
      *) whiptail --title "Error" --msgbox "Invalid selection. Please try again." 8 60 ;;
    esac
    print_separator_en
  done
}

# Hauptfunktion (EN)
main_en() {
  check_and_install_packages_en
  print_separator_en
  main_menu_en
}

################################################################################
# Script Start
################################################################################

start_page
