#!/bin/bash

# Drupal on WSL ASCII art
echo -e "\n"
echo "██████╗░██████╗░██╗░░░██╗██████╗░░█████╗░██╗░░░░░"
echo "██╔══██╗██╔══██╗██║░░░██║██╔══██╗██╔══██╗██║░░░░░"
echo "██║░░██║██████╔╝██║░░░██║██████╔╝███████║██║░░░░░"
echo "██║░░██║██╔══██╗██║░░░██║██╔═══╝░██╔══██║██║░░░░░"
echo "██████╔╝██║░░██║╚██████╔╝██║░░░░░██║░░██║███████╗"
echo "╚═════╝░╚═╝░░╚═╝░╚═════╝░╚═╝░░░░░╚═╝░░╚═╝╚══════╝"
echo "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"
echo "░█████╗░███╗░░██╗  ░██╗░░░░░░░██╗░██████╗██╗░░░░░"
echo "██╔══██╗████╗░██║  ░██║░░██╗░░██║██╔════╝██║░░░░░"
echo "██║░░██║██╔██╗██║  ░╚██╗████╗██╔╝╚█████╗░██║░░░░░"
echo "██║░░██║██║╚████║  ░░████╔═████║░░╚═══██╗██║░░░░░"
echo "╚█████╔╝██║░╚███║  ░░╚██╔╝░╚██╔╝░██████╔╝███████╗"
echo "░╚════╝░╚═╝░░╚══╝  ░░░╚═╝░░╚═╝░░╚═════╝░╚══════╝"
echo -e "\n🚀 Drupal Development Environment on Windows Subsystem Linux (Ubuntu)\n"

# Color definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No color

# Update and upgrade packages
sudo apt update && sudo apt list --upgradable && sudo apt upgrade -y

# Install Nala
sudo apt install nala -y

# Update and upgrade packages
sudo nala update && sudo nala list --upgradable && sudo nala upgrade -y

# Prompt user for optional installations
read -p "Deseja instalar o PostgreSQL? (s/n): " INSTALL_POSTGRES
read -p "Deseja instalar o MariaDB? (s/n): " INSTALL_MARIADB
read -p "Deseja instalar o Sass? (s/n): " INSTALL_SASS

# List of packages to install
PACKAGES=(
  apache2
  software-properties-common
  libapache2-mod-php
  php
  php-apcu
  php-uploadprogress
  php-pear
  ffmpeg
  php-common
  php-ldap
  php-dom
  php-cli
  php-gd
  php-simplexml
  php-zip
  php-xml
  php-mbstring
  php-curl
  php-bcmath
  php-xmlrpc
  php-opcache
  php-soap
  php-intl
  php-imagick
  composer
)

# Conditionally add optional packages
if [[ $INSTALL_POSTGRES =~ ^[Ss]$ ]]; then
  PACKAGES+=(php-pgsql postgresql postgresql-contrib)
fi

if [[ $INSTALL_MARIADB =~ ^[Ss]$ ]]; then
  PACKAGES+=(php-mysql mariadb-server)
fi

if [[ $INSTALL_SASS =~ ^[Ss]$ ]]; then
  PACKAGES+=(nodejs npm)
fi

# Install individual packages using Nala
for PACKAGE in "${PACKAGES[@]}"; do
  sudo nala install -y $PACKAGE
done

# Conditionally install Sass globally via npm
if [[ $INSTALL_SASS =~ ^[Ss]$ ]]; then
  sudo npm install -g sass
fi

# Enable Apache2 rewrite module
sudo a2enmod rewrite

# Add aliases to .bashrc
{
  echo 'alias drush="./vendor/drush/drush/drush"'
  echo 'alias sites="cd /var/www/"'
  echo 'alias vhosts="cd /etc/apache2/sites-available/"'
  echo 'alias update="sudo nala update && sudo nala list --upgradable && sudo nala upgrade -y"'

  # Conditionally add restart aliases
  if [[ $INSTALL_MARIADB =~ ^[Ss]$ ]]; then
    echo 'alias rmdb="sudo service mariadb restart"'
  fi
  if [[ $INSTALL_POSTGRES =~ ^[Ss]$ ]]; then
    echo 'alias rpg="sudo service postgresql restart"'
  fi
  echo 'alias rap="sudo service apache2 restart'
  [[ $INSTALL_MARIADB =~ ^[Ss]$ ]] && echo ' && sudo service mariadb restart'
  [[ $INSTALL_POSTGRES =~ ^[Ss]$ ]] && echo ' && sudo service postgresql restart'
  echo '"'

  # Conditionally add Sass aliases
  if [[ $INSTALL_SASS =~ ^[Ss]$ ]]; then
    echo 'alias ss1="sass scss/style.scss css/style.css -w"'
    echo 'alias ss2="sass scss/ck5style.scss css/ck5style.css -w"'
  fi
  echo 'alias logs="tail -f /var/log/apache2/error.log"'
  echo 'alias phplog="tail -f /var/log/php_errors.log"'
} >> ~/.bashrc

# Modify php.ini
PHP_INI="/etc/php/8.3/apache2/php.ini"
sudo sed -i 's/memory_limit = .*/memory_limit = 512M/' $PHP_INI
sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 512M/' $PHP_INI
sudo sed -i 's/post_max_size = .*/post_max_size = 2048M/' $PHP_INI
sudo sed -i 's/max_execution_time = .*/max_execution_time = 180/' $PHP_INI
sudo sed -i 's/max_input_time = .*/max_input_time = 180/' $PHP_INI

# Restart Apache
sudo systemctl restart apache2

# Check if services are running and display status
echo -e "\nChecking installation status..."

# Function to check service status
check_service() {
  if systemctl is-active --quiet $1; then
    echo -e "${GREEN}✓ $1 is running${NC}"
    return 0
  else
    echo -e "${RED}✗ $1 failed to start${NC}"
    return 1
  fi;
}

# Check essential services
SERVICES=(apache2)
[[ $INSTALL_MARIADB =~ ^[Ss]$ ]] && SERVICES+=(mariadb)
[[ $INSTALL_POSTGRES =~ ^[Ss]$ ]] && SERVICES+=(postgresql)
FAILED=0

for SERVICE in "${SERVICES[@]}"; do
  check_service $SERVICE || ((FAILED++))
done

# Check PHP installation
if command -v php &> /dev/null; then
  echo -e "${GREEN}✓ PHP $(php -v | head -n1 | cut -d' ' -f2) is installed${NC}"
else
  echo -e "${RED}✗ PHP installation failed${NC}"
  ((FAILED++))
fi

# Check Composer installation
if command -v composer &> /dev/null; then
  echo -e "${GREEN}✓ Composer is installed${NC}"
else
  echo -e "${RED}✗ Composer installation failed${NC}"
  ((FAILED++))
fi

# Display final status
echo -e "\nInstallation Summary:"
if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✓ All components installed successfully!${NC}"
else
  echo -e "${RED}✗ Installation completed with $FAILED error(s)${NC}"
fi

# Inform the user to reload .bashrc manually
echo -e "\nPlease run '${GREEN}source ~/.bashrc${NC}' to apply the changes."
