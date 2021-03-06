#!/data/data/com.termux/files/usr/bin/bash

# Author:  Prince Katiyar   (github.com/LxaNce-Hacker)

#colors and other variables.
R='\e[1;31m'
C='\e[0;36m'
B='\e[1;34m'
G='\e[1;32m'
Y='\e[1;33m'
N='\e[0m'
FILE=$(which login)

#Banner
read -r -d '' BANNER << EOF
$B ┌─────────────────────────┐
$B │$C TERMUX FINGERPRINT LOCK $B│
$B └─────────────────────────┘
$R       -> LxaNce👸🤴
EOF


# FUNCTIONS
# Check fingerprint
function authenticate() {
  termux-fingerprint | grep -q "AUTH_RESULT_SUCCESS"
}


# Exit on errors
function error_exit() {
  echo -e "$R\n$0: $1$N" >&2
  exit 1
}


# Check dependency
function check_dependency() {
  if ! type -p termux-fingerprint &>/dev/null; then
    echo -e "$Y[*] Installing Dependencies$B\n"

    (apt-get update && apt-get upgrade -y && \
      apt-get install termux-api -y) || \
      error_exit "NO INTERNET CONNECTION"

    if check_dependency ; then
      echo -e "\n$G[-] Dependencies Installed\n"
    fi
  fi
}


# Catching signal
trap 'echo -e "$N"' 1 15 20


# Show banner
clear
echo -e "${BANNER}\n"


#Check if lock already exists.
if grep -q "termux-fingerprint" $FILE; then
  echo -e "$Y[*] Removing Lock\n"
  echo -e "$R[!] Authentication Required\n"

  sleep 1
  #Authenticate fingerprint, if success delete lock
  if authenticate; then
    sed -i '/termux-fingerprint/d' $FILE

    echo -e "$G[-] Lock Removed$N\n"
    exit 0

  #else exit
  else
    error_exit "Authenticatiin Error"
  fi

#if lock do not exist. set one
else
  check_dependency

  echo -e "$Y[*] Setting Lock\n"
  echo -e "$R[!] Authentication Required\n"

  sleep 1
  #Test if fingerprint working.
  if authenticate; then
    sed -i '2 a termux-fingerprint -c Exit | grep -q "AUTH_RESULT_SUCCESS"; [ $? -ne 0 ] && exit' $FILE

    echo -e "$G[-] Lock Set$N\n"
    exit 0

  #else skip setup and exit
  else
    error_exit "Authenticatiin Error"
  fi
fi
