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
echo -e "\n🚀 Drupal Development Environment on Windows Subsystem for Linux (Ubuntu)\n"

# Color definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No color

# Update and upgrade packages
echo -e "${GREEN}Updating packages...${NC}"
sudo apt update && sudo apt list --upgradable && sudo apt upgrade -y

# Install Nala
echo -e "\n${GREEN}Installing Nala...${NC}"
sudo apt install nala -y

# Update using Nala
echo -e "\n${GREEN}Updating with Nala...${NC}"
sudo nala update && sudo nala list --upgradable && sudo nala upgrade -y

# Prompt user for optional installations
echo -e "\n${GREEN}Optional package configuration:${NC}"
read -p "Install PostgreSQL? (y/n): " INSTALL_POSTGRES
read -p "Install MariaDB? (y/n): " INSTALL_MARIADB
read -p "Install Sass (via npm)? (y/n): " INSTALL_SASS

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
)

# Conditionally add optional packages
if [[ $INSTALL_POSTGRES =~ ^[Yy]$ ]]; then
  PACKAGES+=(php-pgsql postgresql postgresql-contrib)
fi

if [[ $INSTALL_MARIADB =~ ^[Yy]$ ]]; then
  PACKAGES+=(php-mysql mariadb-server)
fi

if [[ $INSTALL_SASS =~ ^[Yy]$ ]]; then
  PACKAGES+=(nodejs npm)
fi

# Install individual packages using Nala
echo -e "\n${GREEN}Installing main packages...${NC}"
for PACKAGE in "${PACKAGES[@]}"; do
  sudo nala install -y "$PACKAGE"
done

# Proper Composer installation
echo -e "\n${GREEN}Installing Composer...${NC}"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === file_get_contents('https://composer.github.io/installer.sig')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); exit(1); }"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
php -r "unlink('composer-setup.php');"

# Conditionally install Sass globally via npm
if [[ $INSTALL_SASS =~ ^[Yy]$ ]]; then
  echo -e "\n${GREEN}Installing Sass...${NC}"
  sudo npm install -g sass
fi

# Enable Apache2 rewrite module
echo -e "\n${GREEN}Configuring Apache...${NC}"
sudo a2enmod rewrite

# Add aliases to .bashrc
echo -e "\n${GREEN}Creating aliases...${NC}"
{
  echo "alias drush=\"./vendor/drush/drush/drush\""
  echo "alias sites=\"cd /var/www/\""
  echo "alias vhosts=\"cd /etc/apache2/sites-available/\""
  echo "alias update=\"sudo nala update && sudo nala list --upgradable && sudo nala upgrade -y\""
  echo "alias upgrade=\"sudo nala install \$(nala list --upgradable | awk '/^[^├└]/ && NF {print \$1}')\""

  RESTART_CMD="sudo service apache2 restart"
  [[ $INSTALL_MARIADB =~ ^[Yy]$ ]] && RESTART_CMD+=" && sudo service mariadb restart"
  [[ $INSTALL_POSTGRES =~ ^[Yy]$ ]] && RESTART_CMD+=" && sudo service postgresql restart"
  echo "alias rap=\"$RESTART_CMD\""

  if [[ $INSTALL_MARIADB =~ ^[Yy]$ ]]; then
    echo "alias rmdb=\"sudo service mariadb restart\""
  fi
  if [[ $INSTALL_POSTGRES =~ ^[Yy]$ ]]; then
    echo "alias rpg=\"sudo service postgresql restart\""
  fi

  if [[ $INSTALL_SASS =~ ^[Yy]$ ]]; then
    echo "alias ss1=\"sass scss/style.scss css/style.css -w\""
    echo "alias ss2=\"sass scss/ck5style.scss css/ck5style.css -w\""
  fi

  echo "alias logs=\"tail -f /var/log/apache2/error.log\""
  echo "alias phplog=\"tail -f /var/log/php_errors.log\""
} >> ~/.bashrc

# Adjust PHP settings
echo -e "\n${GREEN}Adjusting PHP settings...${NC}"
PHP_INI="/etc/php/8.3/apache2/php.ini"
sudo sed -i 's/memory_limit = .*/memory_limit = 512M/' "$PHP_INI"
sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 512M/' "$PHP_INI"
sudo sed -i 's/post_max_size = .*/post_max_size = 2048M/' "$PHP_INI"
sudo sed -i 's/max_execution_time = .*/max_execution_time = 180/' "$PHP_INI"
sudo sed -i 's/max_input_time = .*/max_input_time = 180/' "$PHP_INI"

# Restart Apache
sudo systemctl restart apache2

# Check if services are running and display status
echo -e "\n${GREEN}Checking installation status...${NC}"

check_service() {
  if systemctl is-active --quiet "$1"; then
    echo -e "${GREEN}✓ $1 is running${NC}"
    return 0
  else
    echo -e "${RED}✗ $1 failed to start${NC}"
    return 1
  fi
}

SERVICES=(apache2)
[[ $INSTALL_MARIADB =~ ^[Yy]$ ]] && SERVICES+=(mariadb)
[[ $INSTALL_POSTGRES =~ ^[Yy]$ ]] && SERVICES+=(postgresql)
FAILED=0

for SERVICE in "${SERVICES[@]}"; do
  check_service "$SERVICE" || ((FAILED++))
done

# Check PHP installation
if command -v php &> /dev/null; then
  PHP_VERSION=$(php -v | head -n1 | cut -d' ' -f2)
  echo -e "${GREEN}✓ PHP $PHP_VERSION is installed${NC}"
else
  echo -e "${RED}✗ PHP installation failed${NC}"
  ((FAILED++))
fi

# Check Composer installation
if command -v composer &> /dev/null; then
  COMPOSER_VERSION=$(composer --version | cut -d' ' -f2)
  echo -e "${GREEN}✓ Composer $COMPOSER_VERSION is installed${NC}"
else
  echo -e "${RED}✗ Composer installation failed${NC}"
  ((FAILED++))
fi

# Insert versions function into .bashrc
{
  echo ""
  echo "# Function to display versions of installed software"
  echo "function versions() {"
  echo "  apache_ver=\$(apache2ctl -v 2>/dev/null | grep \"Server version\" | awk '{print \$3}' | sed 's/Apache\\///')"
  echo "  if [ -z \"\$apache_ver\" ]; then"
  echo "    apache_ver=\$(httpd -v 2>/dev/null | grep \"Server version\" | awk '{print \$3}' | sed 's/Apache\\///')"
  echo "  fi"
  echo "  [ -z \"\$apache_ver\" ] && apache_ver=\"Not found\""
  echo ""
  echo "  php_ver=\$(php -v 2>/dev/null | head -n1 | awk '{print \$2}')"
  echo "  [ -z \"\$php_ver\" ] && php_ver=\"Not found\""
  echo ""
  echo "  mariadb_ver=\$(mariadb --version 2>/dev/null | awk '{print \$5}' | sed 's/,//')"
  echo "  [ -z \"\$mariadb_ver\" ] && mariadb_ver=\"Not found\""
  echo ""
  echo "  postgresql_ver=\$(psql --version 2>/dev/null | awk '{print \$3}')"
  echo "  [ -z \"\$postgresql_ver\" ] && postgresql_ver=\"Not found\""
  echo ""
  echo "  sass_ver=\$(sass --version 2>/dev/null | head -n1 | awk '{print \$1}')"
  echo "  [ -z \"\$sass_ver\" ] && sass_ver=\"Not found\""
  echo ""
  echo "  git_ver=\$(git --version 2>/dev/null | awk '{print \$3}')"
  echo "  [ -z \"\$git_ver\" ] && git_ver=\"Not found\""
  echo ""
  echo "  separator=\"--------------------------------------------\""
  echo "  printf \"\\n%s\\n\" \"\$separator\""
  echo "  printf \"%-12s | %-10s\\n\" \"Software\" \"Version\""
  echo "  printf \"%s\\n\" \"\$separator\""
  echo "  printf \"%-12s | %-10s\\n\" \"Apache\" \"\$apache_ver\""
  echo "  printf \"%-12s | %-10s\\n\" \"PHP\" \"\$php_ver\""
  echo "  printf \"%-12s | %-10s\\n\" \"MariaDB\" \"\$mariadb_ver\""
  echo "  printf \"%-12s | %-10s\\n\" \"PostgreSQL\" \"\$postgresql_ver\""
  echo "  printf \"%-12s | %-10s\\n\" \"Sass\" \"\$sass_ver\""
  echo "  printf \"%-12s | %-10s\\n\" \"Git\" \"\$git_ver\""
  echo "  printf \"%s\\n\\n\" \"\$separator\""
  echo "}"
} >> ~/.bashrc

# Final summary
echo -e "\n${GREEN}Installation summary:${NC}"
if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✓ Installation completed successfully! All components were installed correctly.${NC}"
else
  echo -e "${RED}✗ Installation completed with $FAILED errors.${NC}"
fi

echo -e "\nRun '${GREEN}source ~/.bashrc${NC}' to load the new aliases and functions."
echo -e "You can diagnose the installations using the '${GREEN}versions${NC}' command."
echo -e "Please restart your terminal to apply all the configurations.\n"
